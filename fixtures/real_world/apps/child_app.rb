require 'middleman/apps/base'

module RealWorld
  # Child app that inherits from Middleman::Apps::BaseApp (which in turn
  # inherits from Sinatra::Base) for additional features, such as:
  # - error pages will be same as your main middleman static app
  # - views and public folders set appropriately
  # - handly helper methods, etc.
  #
  class ChildApp < ::Middleman::Apps::Base
    get '/' do
      "hello #{named} world"
    end

    get '/test' do
      middleman_layout :test
    end

    get '/page/:str' do
      str = params[:str] || 'testing..'
      middleman_layout :page, locals: { str: str }
    end

    def named
      'my'
    end
  end
end
