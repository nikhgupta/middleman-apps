require 'sinatra'

module RealWorld
  module SomeNamespace
    # Child app that is used by option: namespace
    class IgnoredApp < Sinatra::Base
      get '/' do
        params[:test] ? 'pass' : 'fail'
      end
    end
  end
end
