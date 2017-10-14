# FIXME: Remove this and figure out a way to reload Capybara app?
#
require 'capybara/mechanize'
require 'capybara/mechanize/cucumber'

After do
  ENV['RACK_ENV'] = nil
end

Before '@development' do
  ENV['RACK_ENV'] = 'development'
end

Before '@production' do
  ENV['RACK_ENV'] = 'production'
end

Around '@mechanize' do |_scenario, block|
  current_app = Capybara.app
  Capybara.app = ->(_env) { [200, {}, []] }
  Capybara.app_host = 'localhost:13579'
  Capybara.server_port = 13_579
  Capybara.run_server = true
  Capybara.raise_server_errors = false

  block.call

  Capybara.app = current_app
  Capybara.app_host = nil
  Capybara.server_port = nil
  Capybara.run_server = false
end
