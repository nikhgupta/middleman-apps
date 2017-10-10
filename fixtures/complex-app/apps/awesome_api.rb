require 'sinatra'

module OtherNamespace
  # Child app that tests specifying a specific namespace/class
  # for a single URL endpoint
  class AwesomeAPI < Sinatra::Base
    get '/ping' do
      'pong'
    end
  end
end
