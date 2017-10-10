PROJECT_ROOT_PATH = File.dirname(File.dirname(File.dirname(__FILE__)))
require 'middleman-core'
require 'middleman-core/step_definitions'
require File.join(PROJECT_ROOT_PATH, 'lib', 'middleman/apps')

Before do
  delete_environment_variable 'MM_ROOT'
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
