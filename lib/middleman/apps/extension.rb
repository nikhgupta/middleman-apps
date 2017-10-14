require 'forwardable'
require 'middleman-core'
require 'middleman-core/load_paths'

module Middleman
  module Apps
    # A Middleman extension to serve Rack applications (e.g. created via
    # Sinatra) or other such apps when previewing using Middleman Preview
    # server, as well as in the production (build) mode by creating an umbrella
    # Rack app.
    #
    # Usage examples can be seen in README for this extension.
    #
    class Extension < ::Middleman::Extension
      extend Forwardable
      attr_reader :app_collection
      def_delegators :@app_collection, :apps_list
      expose_to_template :apps_list

      # @!group Options for Extension

      # @!macro [attach] option
      #   @!method $1(value)
      #   Extension Option - $3 - Default: $2
      #   @param value value for this option - Default: `$2`
      option :not_found, '404.html', 'Path to 404 error page'
      option :namespace, nil, 'Namespace for the child apps'
      option :map, {}, 'Mappings for differently named child apps'
      option :verbose, false, 'Displays list of child apps that were ignored'
      option :app_dir, ENV['MM_APPS_DIR'] || 'apps',
             'The directory child apps are stored in'

      # @!endgroup

      def initialize(app, options_hash = {}, &block)
        super
        # useful for converting file names to ruby classes
        require 'active_support/core_ext/string/inflections'
        require 'middleman/sitemap/app_resource'
        require 'middleman/sitemap/app_collection'

        # get a reference to all the apps
       @app_collection = Sitemap::AppCollection.new(app, self, options)
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
        return if app.build?

        app.sitemap.register_resource_list_manipulator(:child_apps, @app_collection)
        return unless app.server?

        watch_child_apps
        @app_collection.mount_child_apps(app)
      end

      # Set a watcher to reload MM when files change in the directory for the
      # child apps.
      #
      # @return [nil]
      #
      def watch_child_apps
        # Make sure it exists, or `listen` will explode.
        app_path = File.expand_path(options.app_dir, app.root)
        ::FileUtils.mkdir_p(app_path)
        watcher = app.files.watch :reload, path: app_path, only: /\.rb$/
        list = @app_collection
        watcher.on_change { list.mount_child_apps(app) }
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

        content = <<-CONTENT.gsub(/^ {8}/, '')
        ENV['RACK_ENV'] ||= 'production'
        require 'middleman/apps'
        run Middleman::Apps.rack_app
        CONTENT

        File.open(path, 'wb') { |file| file.puts content }
      end
    end
  end
end
