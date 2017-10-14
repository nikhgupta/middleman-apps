require 'capybara/poltergeist'

Capybara.default_driver = :rack_test
Capybara.register_driver :poltergeist do |app|
  options = {
    js_errors: true,
    timeout: 120,
    debug: false,
    phantomjs_options: ['--load-images=no', '--disk-cache=false'],
    inspector: true
  }
  Capybara::Poltergeist::Driver.new(app, options)
end
Capybara.javascript_driver = :poltergeist

After do
  ENV['RACK_ENV'] = nil
end

Before '@development' do
  ENV['RACK_ENV'] = 'development'
end

Before '@production' do
  ENV['RACK_ENV'] = 'production'
end

Before '@reload' do
  $LOADED_FEATURES.reject! { |f| f =~ %r{/tmp/aruba/} }
  $LOADED_FEATURES.reject! { |f| f =~ %r{middleman/apps/base\.rb} }

  %i[RealWorld OtherNamespace Simple].each do |const|
    Object.send :remove_const, const if Object.const_defined? const
  end
end
