require 'sinatra'

# Test application fixture
class TestApp < Sinatra::Base
  get '/' do
    params[:test] ? 'pass' : 'fail'
  end
end
