require 'sinatra'

module ComplexApp
  module SomeNamespace
    # Child app that is used by option: namespace
    class TestApp < Sinatra::Base
      get '/' do
        params[:test] ? 'pass' : 'fail'
      end
    end
  end
end
