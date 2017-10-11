PROJECT_ROOT_PATH = File.dirname(File.dirname(File.dirname(__FILE__)))
require 'middleman-core'
require 'middleman-core/step_definitions'
require 'capybara/mechanize'
require 'capybara/mechanize/cucumber'
require File.join(PROJECT_ROOT_PATH, 'lib', 'middleman/apps')

Before do
  delete_environment_variable 'MM_ROOT'
  # Require sinatra reloader here so that it does not interfere with test suite
  # when it runs. Sinatra::Reloader has vodoo magic that loads previously
  # referenced files and makes reloading possible for us.
  #
  # However, when we switch to next scenario, we no longer have references to
  # temporary aruba files that were created, and Sinatra::Reloader complains
  # about this. So, hush hush!!
  require 'sinatra/reloader'
end

After do
  delete_environment_variable 'MM_ROOT'
  ENV['MM_ROOT'] = nil
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

module Aruba
  module Platforms
    # Turn off deprecation warnings from Aruba,
    # atleast on my current system :)
    class UnixPlatform
      def deprecated(*_args); end
    end
  end
end
