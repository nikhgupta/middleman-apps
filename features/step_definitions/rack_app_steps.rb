Given(/^(?:|successfully built )?app is running(?:| at "([^\"]*)")?$/) do |*args|
  step %(a fixture app "#{args[0]}") if args.any?
  step %(I run `middleman build --verbose`)
  step %(was successfully built)

  app = nil
  path = File.expand_path(expand_path('.'))
  ENV['MM_ROOT'] = path

  Dir.chdir(path) do
    app, = Rack::Builder.parse_file('config.ru')
  end

  # a built app that is running is always in production mode
  ENV['RACK_ENV'] = 'production'
  Capybara.app = app.to_app
end
