require 'middleman-core'

# Load extension nonetheless, as child apps may/will require this file.
require 'middleman-apps/extension'

# Register this extension with the name of `apps`
Middleman::Extensions.register :apps, Middleman::Apps
