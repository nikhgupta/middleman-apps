require 'middleman/apps/base'

module RealWorld
  # Child app that is used by option: namespace
  class TestApp < Middleman::Apps::Base
    get '/' do
      params[:test] ? 'pass' : 'fail'
    end

    get '/metadata' do
      metadata.map do |key, val|
        "#{key} => #{val}"
      end.join("\n")
    end
  end
end
