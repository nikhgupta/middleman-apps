require 'sinatra'

module ComplexApp
  module SomeNamespace
    # Test application fixture
    class TestApp < Sinatra::Base
      get '/' do
        params[:test] ? 'pass' : 'fail'
      end
    end
  end
end
