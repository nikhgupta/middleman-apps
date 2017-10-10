require 'sinatra'

module Middleman
  class Apps
    # Base application class for creating child applications.
    #
    # Inheriting from this class should provide better syncronization with the
    # static middleman app.
    #
    class BaseApp < Sinatra::Base
      # set :static, true

      # set :mm_root, File.dirname(File.dirname(__FILE__))
      # set :mm_dir, settings.development? ? 'source' : 'build'
      # set :public_folder, File.join(settings.mm_root, settings.mm_dir)
      # set :views, settings.public_folder

      not_found do
        send_file path_for_not_found, status: 404
      end

      protected

      def middleman_app
        Middleman::Apps.middleman_app
      end

      def path_for_not_found
        Middleman::Apps.within_extension do
          path = find_resource(options.not_found)
          app.root_path.join(app.config.build_dir, path).to_s
        end
      end
    end
  end
end
