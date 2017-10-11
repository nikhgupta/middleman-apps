require 'middleman-core'

# Load extension nonetheless, as child apps may/will require this file.
require 'middleman/apps/extension'

# Register this extension with the name of `apps`
Middleman::Extensions.register :apps, Middleman::Apps::Extension

module Middleman
  # Base namespace for `middleman-apps` extension.
  #
  module Apps
    # Environment in which MM should be run
    ENVIRONMENT = (ENV['MM_ENV'] || ENV['RACK_ENV'] || 'development').to_sym

    # Middleman options that would be passed to create a reference instance.
    MIDDLEMAN_OPTIONS = {
      mode: :config,
      watcher_disable: true,
      exit_before_ready: true,
      environment: ENVIRONMENT
    }.freeze

    # Middleman app instance for reference to configuration, etc.
    #
    # @return [Middleman::Application] an instance of {Middleman::Application}
    #   using configuration in {MIDDLEMAN_OPTIONS}
    #
    def self.middleman_app
      Middleman.setup_load_paths

      ::Middleman::Application.new do
        MIDDLEMAN_OPTIONS.each do |key, val|
          config[key] = val
        end
      end
    end

    # Evaluate some code within the context of this extension.
    #
    # @param [Proc] block block to be executed
    # @return [Any] - result of execution of the provided block
    #
    # @see .rack_app `.rack_app` method which uses this internally
    #
    def self.within_extension(app = nil, &block)
      app ||= middleman_app
      options = app.extensions[:apps].options.to_h
      ext = Middleman::Apps::Extension.new(app, options)
      block ? ext.instance_eval(&block) : ext
    end

    # Rack app comprising of the static (middleman) app with 404 pages, and
    # child apps properly mounted.
    #
    # This method can be used directly to create a Rack app. Refer to the
    # generated `config.ru` for an example.
    #
    # @return [Rack::App] rack application configuration
    def self.rack_app
      within_extension do
        # create_config_ru
        mount_child_apps(middleman_static_app)
      end
    end
  end
end
