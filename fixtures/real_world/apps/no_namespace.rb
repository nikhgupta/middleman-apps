require 'sinatra'

# A child app without any namespace attached
class NoNamespaceApp < Sinatra::Base
  get '/' do
    'pass'
  end
end
