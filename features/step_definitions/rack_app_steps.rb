def development?
  ENV['RACK_ENV'] == 'development'
end

def production?
  ENV['RACK_ENV'] == 'production'
end

Given(/app is running(?: with config:)?/) do |*args|
  step %(I overwrite the file named "config.rb" with:), args[0] if args.any?
  step %(I run `middleman build --verbose`)
  step %(was successfully built)

  app = nil
  path = File.expand_path(expand_path('.'))
  ENV['MM_ROOT'] = path

  Dir.chdir(path) do
    app, = Rack::Builder.parse_file('config.ru')
  end

  Capybara.app = app.to_app
end

Given(/^server is running in background$/) do
  if development?
    step %(I run `middleman server -p #{Capybara.server_port}` in background)
  elsif production?
    step %(I run `middleman build --clean`) ## trigger generation of config.ru
    step %(I run `rackup -p #{Capybara.server_port}` in background)
  else
    raise 'You must set @development or @production tag before using this step'
  end
  sleep 4

  # TODO: match partial output from background process in aruba?
  # step %(I wait for stdout to contain "View your site at")
end

When(/^I go to "([^\"]*)" on local server$/) do |path|
  sleep 3 # wait to ensure path has reloaded if required
  visit "http://#{Capybara.server_host}:#{Capybara.server_port}#{path}"
end

Then(/^debug$/) do
  require 'pry'; binding.pry
end
