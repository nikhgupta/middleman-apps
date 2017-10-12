module Middleman
  module Sitemap
    # Base app resource that inherits from Sitemap Resource.
    #
    class AppResource < Resource
      # Get class for this child app.
      #
      # @return [Class] class for the child app
      #
      def klass
        locals['class']
      end
    end
  end
end
