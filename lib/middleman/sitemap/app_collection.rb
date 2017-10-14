module Middleman
  module Sitemap
    # Resource manipulator class that handles list of all our child app
    # resources.
    #
    # To evaluate anything in the context of an instance of this class, use:
    #
    #   Middleman::Apps.with_app_list do
    #     apps_list # => this will be returned by the block
    #   end
    #
    class AppCollection
      def initialize(app, _extension, options = {})
        @app = app
        @options = options
        @sitemap = app.sitemap
        @app_dir = app.root_path.join(options.app_dir)
      end

      # Add our child apps to the list of resources managed by MM.
      #
      # @param [Array<Middleman::Sitemap::Resource>] resources - resource list
      # @return [Array<Middleman::Sitemap::Resource>] updated resource list
      #
      def manipulate_resource_list(resources)
        resources + apps_list
      end

      # Get a list of all child app resources found in child apps directory.
      #
      # All child apps will be reloaded everytime this method is called.
      #
      # @return [Array<Middleman::Sitemap::AppResource>] array of child apps
      #
      def apps_list
        Dir[@app_dir.join('*.rb').to_s].map do |file|
          path = Pathname.new(file)
          resource = create_app(path) if path.file?
          warn "Ignored child app: #{path}" unless resource
          resource
        end.compact
      end

      # Create or reload child app resource for each found child app.
      #
      # @param [String] path to the child app source file
      # @return [Middleman::Sitemap::AppResource] app resource
      #
      def create_app(path)
        reload_resource_at path
        url    = get_application_url_for(path)
        klass  = get_application_class_for(path)
        return unless klass

        source = get_source_file(path, @app_dir, :app)
        title  = (klass || url).to_s.titleize
        AppResource.new(@sitemap, url.gsub(%r{^\/}, ''), source).tap do |p|
          p.add_metadata locals: { url: url, klass: klass, title: title }
        end
      end

      # Mount all child apps on a specific Rack app (or current app)
      #
      # Warning is raised (if `verbose` option is `true`) when a child app was
      # found, but could not be mapped due to the specified config.
      #
      # @param [Rack::App] rack_app app on which to mount child apps
      #                             Default: app from MM configuration
      #
      # @return [Rack::App] rack_app with child apps mounted on top
      #
      def mount_child_apps(rack_app = nil)
        rack_app ||= @app
        apps_list.each do |res|
          rack_app.map(res.url) { run res.klass } if res.klass
        end
        rack_app
      end

      # Get a Rack::App that can serve the MM app's build directory.
      #
      # Directory paths, and 404 error page are deduced from extensions'
      # options.
      #
      # @return [Rack::App] Rack::TryStatic app for MM app's build directory.
      #
      def middleman_static_app
        not_found = @options.not_found
        return create_static_app(root) unless not_found

        not_found_path = File.join(build_dir, find_resource(not_found))
        create_static_app build_dir, not_found_path
      end

      protected

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

        # require 'rack/contrib'
        require 'middleman/apps/rack_contrib'
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
        sitemap    = @app.sitemap
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
        @app.logger.warn(message) if @app.logger && @options.verbose
      end

      # Get path to MM's build dir.
      #
      # @return [String] path to build dir
      #
      def build_dir
        @app.root_path.join(@app.config.build_dir.to_s)
      end

      # Convert options data to a hash for easy searches.
      #
      # @api private
      # @return [Hash] options data
      #
      def mappings
        @options.map.map { |key, val| [key.to_s, val] }.to_h
      end

      # Get URL at which given child app should be mounted.
      #
      # @api private
      # @param [String] path - path to child app
      # @return [String] url component for the child app
      #
      def get_application_url_for(path)
        name  = path.basename('.rb').to_s
        url   = mappings[name]
        url   = url[:url] if url.is_a?(Hash)
        url ||= name.to_s.titleize.parameterize
        "#{@options.mount_path}/#{url}".gsub(%r{\/+}, '/')
      end

      # Get Application Class for the child app.
      #
      # @api private
      # @param [String] path - path to child app
      # @return [Class, nil] Class for the child app, if exists.
      #
      def get_application_class_for(path)
        name = path.basename('.rb').to_s
        namespace = @options.namespace

        klass   = mappings[name][:class] if mappings[name].is_a?(Hash)
        klass ||= namespace ? "#{namespace}/#{name}" : name
        klass.to_s.classify.safe_constantize
      end

      # Get SourceFile instance from the given path.
      #
      # @api private
      # @param [String] path - path to the source file
      # @return [Middleman::SourceFile]
      def get_source_file(path, dir, name)
        ::Middleman::SourceFile.new(path.relative_path_from(dir),
                                    path, path.dirname.to_s, Set.new([name]), 0)
      end

      # Reload resource at a given file path
      #
      # @api private
      # @param [String] path - path to the source file
      # @return [nil]
      #
      def reload_resource_at(path)
        if $LOADED_FEATURES.include?(path.to_s)
          klass = get_application_class_for(path)
          container = klass.to_s.deconstantize.safe_constantize || Object
          container.send(:remove_const, klass.to_s.demodulize) if klass
          $LOADED_FEATURES.delete(path.to_s)
        end

        require path
      end
    end
  end
end
