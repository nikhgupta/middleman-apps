require 'sinatra'

module AssetHash
  # Test application fixture
  class TestApp < Sinatra::Base
    get '/' do
      str = params[:test] ? 'pass' : 'fail'
      middleman_layout :page, locals: { str: str }
    end
  end
end
