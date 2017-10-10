require 'sinatra'

module OtherNamespace
  class AwesomeAPI < Sinatra::Base
    get '/ping' do
      "pong"
    end
  end
end
