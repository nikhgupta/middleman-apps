require 'middleman/apps/base'

module OtherNamespace
  # Child app that tests specifying a specific namespace/class
  # for a single URL endpoint
  class AwesomeAPI < Middleman::Apps::Base
    post '/' do
      status 201
      '201 Created'
    end

    get '/ping' do
      'pong'
    end

    add_routes_to_metadata
    set_metadata :arbitrary, 'defined'
    set_metadata :title, 'Awesome API'
    set_metadata :description, <<-MARKDOWN
      ## Awesome API v3

      A markdown formatted description for this `Awesome API` can be provided
      here. It, also, serves as a simple documentation for anyone reading your
      code later.

      You can even set this method from outside this class like this:

          description = File.read('long_docs_for_simple_api.md')
          OtherNamespace::AwesomeAPI.set :page_description, description

      Enough now!
    MARKDOWN

    get '/metadata' do
      metadata.map do |key, val|
        "#{key} => #{val}"
      end.join("\n")
    end
  end
end
