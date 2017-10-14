require 'sinatra'

module OtherNamespace
  # Test application fixture
  class IgnoredApp < Sinatra::Base
    get '/' do
      params[:test] ? 'pass' : 'fail'
    end
  end
end
