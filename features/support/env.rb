PROJECT_ROOT_PATH = File.dirname(File.dirname(File.dirname(__FILE__)))
require 'middleman-core'
require 'middleman-core/step_definitions'
require File.join(PROJECT_ROOT_PATH, 'lib', 'middleman/apps')

Before do
  # Require sinatra reloader here so that it does not interfere with test suite
  # when it runs. Sinatra::Reloader has vodoo magic that loads previously
  # referenced files and makes reloading possible for us.
  #
  # However, when we switch to next scenario, we no longer have references to
  # temporary aruba files that were created, and Sinatra::Reloader complains
  # about this. So, hush hush!!
  require 'sinatra/reloader'
end
