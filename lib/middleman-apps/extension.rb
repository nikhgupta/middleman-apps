require 'rack/contrib'
require 'middleman-core'
require 'middleman-core/load_paths'

module Middleman
  # Middleman extension to load dynamic/modular pages/apps for Middleman.
  class Apps < Extension
    option :not_found, '404.html', 'Path to 404 error page'
    option :namespace, false, 'Namespace for the modular apps'
    option :map, {}, 'Mappings for differently named modular apps'

    class << self
      ENVIRONMENT = (ENV['MM_ENV'] || ENV['RACK_ENV'] || 'development').to_sym

      OPTIONS = {
        mode: :config,
        watcher_disable: true,
        # disable_sitemap: true,
        exit_before_ready: true,
        environment: ENVIRONMENT
      }.freeze

      def middleman_app
        Middleman.setup_load_paths

        ::Middleman::Application.new do
          OPTIONS.each do |key, val|
            config[key] = val
          end
        end
      end

      def rack_app
        app = middleman_app
        options = app.extensions[:apps].options.to_h
        ext = new(app, options)
        ext.mount_modular_apps(ext.middleman_static_app)
      end
    end

    def initialize(app, options_hash = {}, &block)
      super
      require 'active_support/core_ext/string/inflections'
    end

    def after_configuration
      create_config_ru
      return unless app.server?
      mount_modular_apps(app)
    end

    def mount_modular_apps(rack_app = nil)
      rack_app ||= app
      modular_apps.each do |url, klass|
        rack_app.map(url) { run klass }
      end
      rack_app
    end

    def create_config_ru
      path = File.join(app.root, 'config.ru')
      return if File.exist?(path)

      content = <<-CONTENT.gsub(/^ {6}/, '')
      ENV['RACK_ENV'] = 'production'
      require 'middleman-apps'
      run Middleman::Apps.rack_app
      CONTENT

      File.open(path, 'wb') { |file| file.puts content }
    end

    def modular_apps
      apps_list.map do |mapp|
        require mapp
        klass = get_application_class_for(mapp)
        next unless klass
        ['/' + get_application_url_for(mapp), klass]
      end.compact.to_h
    end

    def middleman_static_app
      root = File.expand_path(app.config.build_dir.to_s)
      not_found = File.join(root, find_resource(options.not_found))
      create_static_app root, not_found
    end

    def apps_list
      pattern = File.join(app.root, 'apps', '*.rb')
      Dir[pattern].map do |file|
        File.realpath(file) if File.file?(file)
      end.compact
    end

    def create_static_app(root, not_found)
      ::Rack::Builder.new do
        use ::Rack::TryStatic, urls: ['/'], root: root,
                               try: ['.html', 'index.html', '/index.html']
        args = File.exist?(not_found) ? [not_found] : []
        run ::Rack::NotFound.new(*args)
      end
    end

    private

    def mappings
      options.map.map { |key, val| [key.to_s, val] }.to_h
    end

    def get_application_class_for(file)
      name = File.basename(file, '.rb')
      namespace = options.namespace
      data = mappings[name]

      klass   = data[:namespace] if data.is_a?(Hash) && data[:namespace]
      klass ||= data unless data.is_a?(Hash)
      klass ||= namespace ? "#{namespace}/#{name}" : name
      klass.to_s.classify.constantize
    rescue NameError
      return nil
    end

    def get_application_url_for(file)
      name = File.basename(file, '.rb')
      data = mappings[name]
      data.is_a?(Hash) ? data[:url] : name.titleize.parameterize
    end

    def find_resource(name)
      sitemap = app.sitemap
      resource   = sitemap.find_resource_by_path(name)
      resource ||= sitemap.find_resource_by_destination_path(name)
      resource ||= sitemap.find_resource_by_page_id(name)
      resource ? resource.destination_path : name
    end
  end
end
