require 'sinatra'
require 'sinatra/reloader'

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

      # @!attribute [r] environment
      #   Set environment for this child application via Middleman.
      #
      #   If `MM_ENV` is set, it is used. Otherwise, we fall back to `RACK_ENV`.
      #   If both environment variables are not set, we set this to
      #   `:development`
      set :environment, Middleman::Apps::ENVIRONMENT

      # @!attribute [r] mm_app
      #   Middleman Application instance for references to config, sitemap, etc.
      #
      #   Lazily evaluated since this is a bit costly.
      #
      set :mm_app, -> { Middleman::Apps.middleman_app }

      # @!attribute [r] views
      #   Path to the directory containing our layout files.
      set :views, -> { File.join(settings.mm_app.root, 'source', 'layouts') }

      configure :production do
        # @!attribute [r] public_folder
        #   Path to the directory containing our layout files.
        set :public_folder, -> { File.join(settings.mm_app.root, 'build') }
      end

      configure :development do
        register Sinatra::Reloader
        set :show_exceptions, true
        set :public_folder, -> { File.join(settings.mm_app.root, 'source') }
      end

      not_found do
        status 404
        Middleman::Apps.not_found(settings.mm_app)
      end

      protected

      # Render a MM layout with the given name.
      #
      def middleman_layout(name, options = {})
        options = { locals: {} }.merge(options)
        context = Class.new(Middleman::TemplateContext).new(settings.mm_app)
        context.render :middleman, "layouts/#{name}", options
      end
    end
  end
end
