require 'sinatra'
require 'sinatra/reloader'

module Middleman
  module Apps
    # Base application class for creating child applications.
    #
    # Inheriting from this class should provide better syncronization with the
    # static middleman app.
    #
    class Base < ::Sinatra::Base
      def self.setr(key, &block)
        configure(:development) { set key, block }
        configure(:production) { set key, block.call }
      end

      set :static, true
      set :environment, Middleman::Apps::ENVIRONMENT

      setr(:mm_app) { Middleman::Apps.middleman_app }
      setr(:views) { File.join(settings.mm_app.root, 'source', 'layouts') }
      setr(:public_folder) { File.join(settings.mm_app.root, 'source') }

      # set :show_exceptions, false
      configure :development do
        register Sinatra::Reloader
        set :show_exceptions, true
      end

      not_found do
        send_file path_for_not_found, status: 404
      end

      protected

      def middleman_layout(name, options = {})
        options = { locals: {} }.merge(options)
        context = Class.new(Middleman::TemplateContext).new(settings.mm_app)
        context.render :middleman, "layouts/#{name}", options
      end

      def path_for_not_found
        Middleman::Apps.within_extension(settings.mm_app) do
          path = find_resource(options.not_found)
          app.root_path.join(app.config.build_dir, path).to_s
        end
      end
    end
  end
end
