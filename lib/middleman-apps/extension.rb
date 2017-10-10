require 'rack/contrib'
require 'middleman-core'

module Middleman
  class Apps < Extension
    option :not_found, '404.html', 'Path to 404 error page'

    class << self
      def middleman_app
        require 'middleman-core/load_paths'
        Middleman.setup_load_paths

        ::Middleman::Application.new do
          config[:environment] = (ENV['MM_ENV'] || ENV['RACK_ENV'] || 'development').to_sym
          config[:mode] = :config
          config[:exit_before_ready] = true
          config[:watcher_disable] = true
          config[:disable_sitemap] = true
        end
      end

      def rack_app
        app = middleman_app
        options = app.extensions[:apps].options.to_h
        ext = new(app, options)
        app = ext.middleman_static_app
        ext.modular_apps.each do |path, klass|
          app.map(path) { run klass }
        end
        app
      end
    end

    def initialize(app, options_hash = {}, &block)
      super
      require 'sinatra'
      require 'active_support/core_ext/string/inflections'
    end

    def after_configuration
      create_config_ru
      return unless app.server?
      modular_apps.each do |path, klass|
        app.map(path) { run klass }
      end
    end

    def create_config_ru
      path = File.join(app.root, 'config.ru')
      return if File.exist?(path)

      content = <<-CONTENT.gsub(/^ {8}/, '')
      ENV['RACK_ENV'] = 'production'
      require 'middleman-apps'
      run Middleman::Apps.rack_app
      CONTENT

      File.open(path, 'wb') { |f| f.puts content }
    end

    def modular_apps
      apps_list.map do |mapp|
        require mapp
        name = File.basename(mapp, '.rb')
        ['/' + name.titleize.parameterize, name.classify.constantize]
      end.compact.to_h
    end

    def middleman_static_app
      root = File.expand_path(app.config.build_dir.to_s)
      not_found = File.join(root, options.not_found)

      ::Rack::Builder.new do
        use ::Rack::TryStatic, urls: ['/'],
                               root: root,
                               try: ['.html', 'index.html', '/index.html']

        args = File.exist?(not_found) ? [not_found] : []
        run ::Rack::NotFound.new(*args)
      end
    end

    def apps_list
      pattern = File.join(app.root, 'apps', '*.rb')
      Dir[pattern].map { |f| File.realpath(f) if File.file?(f) }.compact
    end
  end
end
