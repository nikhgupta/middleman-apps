require 'middleman/apps/base'

module ComplexApp
  # Child app that inherits from Middleman::Apps::BaseApp (which in turn
  # inherits from Sinatra::Base) for additional features, such as:
  # - error pages will be same as your main middleman static app
  # - views and public folders set appropriately
  # - handly helper methods, etc.
  #
  class ChildApp < ::Middleman::Apps::Base
    get '/' do
      'hello'
    end
  end
end
