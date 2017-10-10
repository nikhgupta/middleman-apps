require 'rack/contrib'
require 'middleman-core'
require 'middleman-core/load_paths'

module Middleman
  # A Middleman extension to serve Rack applications (e.g. created via Sinatra)
  # or other such apps when previewing using Middleman Preview server, as well
  # as in the production (build) mode by creating an umbrella Rack app.
  #
  # Usage examples can be seen in README for this extension.
  #
  class Apps < Extension
    class << self
      # Environment in which MM should be run
      ENVIRONMENT = (ENV['MM_ENV'] || ENV['RACK_ENV'] || 'development').to_sym

      # Middleman options that would be passed to create a reference instance.
      MIDDLEMAN_OPTIONS = {
        mode: :config,
        watcher_disable: true,
        exit_before_ready: true,
        environment: ENVIRONMENT
      }.freeze

      # Middleman app instance for reference to configuration, etc.
      #
      # @return [Middleman::Application] an instance of {Middleman::Application}
      #   using configuration in {MIDDLEMAN_OPTIONS}
      #
      # @todo
      #   [MAYBE] move this Utility method to: `Middlemap.to_app` method?
      #   Although, polluting parent app is a bad idea, but is definitely
      #   a useful utility function for custom Rack app based MM extensions?
      #
      def middleman_app
        Middleman.setup_load_paths

        ::Middleman::Application.new do
          MIDDLEMAN_OPTIONS.each do |key, val|
            config[key] = val
          end
        end
      end

      # Evaluate some code within the context of this extension.
      #
      # @param [Proc] block block to be executed
      # @return [Any] - result of execution of the provided block
      #
      # @see .rack_app `.rack_app` method which uses this internally
      #
      def within_extension(&block)
        app = middleman_app
        options = app.extensions[:apps].options.to_h
        new(app, options).instance_eval(&block)
      end

      # Rack app comprising of the static (middleman) app with 404 pages, and
      # child apps properly mounted.
      #
      # This method can be used directly to create a Rack app. Refer to the
      # generated `config.ru` for an example.
      #
      # @return [Rack::App] rack application configuration
      def rack_app
        within_extension do
          mount_child_apps(middleman_static_app)
        end
      end
    end

    # @!group Options for Extension

    # @!macro [attach] option
    #   @!method $1(value)
    #   Extension Option - $3 - Default: $2
    #   @param value value for this option - Default: `$2`
    option :not_found, '404.html', 'Path to 404 error page'
    option :namespace, nil, 'Namespace for the child apps'
    option :map, {}, 'Mappings for differently named child apps'
    option :verbose, false, 'Displays list of child apps that were ignored'

    # @!endgroup

    def initialize(app, options_hash = {}, &block)
      super
      # useful for converting file names to ruby classes
      require 'active_support/core_ext/string/inflections'
    end

    # Mount all child apps on a specific Rack app (or current app)
    #
    # @param [Rack::App] rack_app app on which to mount child apps
    #                             Default: app from MM configuration
    #
    # @return [Rack::App] rack_app with child apps mounted on top
    #
    def mount_child_apps(rack_app = nil)
      rack_app ||= app
      child_apps.each do |url, klass|
        rack_app.map(url) { run klass }
      end
      rack_app
    end

    # Get a hash of all child applications URLs paths matched to corresponding
    # Ruby classes.
    #
    # Warning is raised (if `verbose` option is `true`) when a child app was
    # found, but could not be mapped due to the specified config.
    #
    # @return [Hash] - child application URL vs Ruby class
    #
    def child_apps
      apps_list.map do |mapp|
        require mapp
        klass = get_application_class_for(mapp)
        warn "Ignored child app: #{mapp}" unless klass
        [get_application_url_for(mapp), klass] if klass
      end.compact.to_h
    end

    # Get a Rack::App that can serve the MM app's build directory.
    #
    # Directory paths, and 404 error page are deduced from extensions' options.
    #
    # @return [Rack::App] Rack::TryStatic app for MM app's build directory.
    #
    def middleman_static_app
      not_found = options.not_found
      return create_static_app(root) unless not_found

      not_found_path = File.join(build_dir, find_resource(not_found))
      create_static_app build_dir, not_found_path
    end

    # Get a list of all child apps that are found in `MM_ROOT/apps` directory.
    #
    def apps_list
      pattern = File.join(app.root, 'apps', '*.rb')
      Dir[pattern].map do |file|
        File.realpath(file) if File.file?(file)
      end.compact
    end

    # Run `after_configuration` hook passed on by MM
    #
    # After configuration for middleman has been finalized,
    # create a `config.ru` in the root directory, and mount all child
    # apps, if we are on a preview server.
    #
    # @return [nil]
    #
    # @private
    # @api private
    #
    def after_configuration
      create_config_ru
      return unless app.server?
      mount_child_apps(app)
    end

    # Create a `config.ru` file, if one does not exist, yet.
    #
    # This is done whenever `middleman` cli is run for building, or previewing
    # the static app.
    #
    # @return [nil]
    #
    # @private
    # @api private
    #
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

    # Create a Rack::TryStatic application for the given directory root.
    #
    # @param [String] root - path to directory root
    # @param [String] path - path to not found error page
    #                        If not provided, default 404 response from Rack
    #                        is served.
    #
    # @return [Rack::App] static app for the `root` directory
    #
    # @api private
    #
    def create_static_app(root, path = nil)
      unless File.exist?(path)
        warn("Could not find: #{path}")
        path = nil
      end

      ::Rack::Builder.new do
        use ::Rack::TryStatic, urls: ['/'], root: root,
                               try: ['.html', 'index.html', '/index.html']
        run ::Rack::NotFound.new(path)
      end
    end

    # Find a resource given its path, destination path, or page_id.
    #
    # @param [String] name - identifier for this resource
    # @return [String] relative path to resource
    #
    # @api private
    #
    def find_resource(name)
      sitemap    = app.sitemap
      resource   = sitemap.find_resource_by_path(name)
      resource ||= sitemap.find_resource_by_destination_path(name)
      resource ||= sitemap.find_resource_by_page_id(name)
      resource ? resource.destination_path : name
    end

    private

    # Warn user about message if `verbose` option is on.
    #
    # @param [String] message - message to display
    #
    # @private
    # @api private
    #
    def warn(message)
      logger.warn(message) if logger && options.verbose
    end

    # Get path to MM's build dir.
    #
    # @return [String] path to build dir
    #
    def build_dir
      File.expand_path(app.config.build_dir.to_s)
    end

    # Convert options data to a hash for easy searches.
    #
    # @api private
    # @return [Hash] options data
    #
    def mappings
      options.map.map { |key, val| [key.to_s, val] }.to_h
    end

    # Get URL at which given child app should be mounted.
    #
    # @api private
    # @param [String] file - path to child app
    # @return [String] url component for the child app
    #
    def get_application_url_for(file)
      name = File.basename(file, '.rb')
      url  = mappings[name]
      url  = url[:url] if url.is_a?(Hash)
      '/' + (url ? url.to_s.gsub(%r{^\/}, '') : name.titleize.parameterize)
    end

    # Get Application Class for the child app.
    #
    # @api private
    # @param [String] file - path to child app
    # @return [Class, nil] Class for the child app, if exists.
    #
    def get_application_class_for(file)
      name = File.basename(file, '.rb')
      namespace = options.namespace

      klass   = mappings[name][:class] if mappings[name].is_a?(Hash)
      klass ||= namespace ? "#{namespace}/#{name}" : name
      klass.to_s.classify.constantize
    rescue NameError
      return nil
    end
  end
end
