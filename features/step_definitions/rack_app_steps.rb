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
