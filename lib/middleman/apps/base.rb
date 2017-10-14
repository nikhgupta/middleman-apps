require 'sinatra'
require 'middleman/apps'

module Middleman
  module Apps
    # Base application class for creating child applications.
    #
    # Inheriting from this class provides better integration with the static
    # middleman app.
    #
    class Base < ::Sinatra::Base
      # @!attribute [r] static
      #   Serve static assets from #public_folder, if found
      set :static, true

      set :environment, (ENV['RACK_ENV'] || 'development').to_sym

      # @!attribute [r] mm_app
      #   Middleman Application instance for references to config, sitemap, etc.
      #
      #   Lazily evaluated since this is a bit costly.
      #
      set :mm_app, Middleman::Apps.middleman_app

      # @!attribute [r] views
      #   Path to the directory containing our layout files.
      set :views, File.join(settings.mm_app.root, 'source', 'layouts')

      # @!attribute [r] public_folder
      #   Path to the directory containing our layout files.
      set :public_folder, File.join(settings.mm_app.root, 'build')

      configure :development do
        set :show_exceptions, true
      end

      not_found do
        status 404
        Middleman::Apps.not_found(settings.mm_app)
      end

      def self.app_resource
        Middleman::Apps.find_app_resource_for(self, settings.mm_app)
      end

      def self.metadata
        res  = app_resource
        data = res ? res.locals : {}
        keys = %i[routes html_description]
        data = keys.map { |key| [key, res.send(key)] }.to_h.merge(data) if res
        Hashie::Mash.new(data)
      rescue NameError
        data
      end

      def self.set_metadata(key, val, overwrite: false)
        return if !overwrite && settings.respond_to?("app_#{key}")
        set "app_#{key}", val
        app_resource && app_resource.update_locals(key, val)
      end

      def self.add_routes_to_metadata(*verbs)
        verbs = %i[get post put patch delete] if verbs.empty?
        app_routes = verbs.map do |verb|
          (routes[verb.to_s.upcase] || []).map do |route|
            "##{verb.to_s.upcase} #{route[0]}"
          end
        end.flatten
        set_metadata :routes, app_routes, overwrite: true
      end

      protected

      def metadata
        self.class.metadata
      end

      # Render a MM layout with the given name.
      #
      def middleman_layout(name, opts = {})
        locs = opts.delete(:locals) || {}
        opts[:layout] ||= name

        res = self.class.app_resource
        res.render(opts, res.locals.merge(locs))
      end
    end
  end
end
