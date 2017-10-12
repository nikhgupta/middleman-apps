Before do
  delete_environment_variable 'MM_ROOT'
end

After do
  delete_environment_variable 'MM_ROOT'
  ENV['MM_ROOT'] = nil
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
