Given(/app is running(?: with config:)?/) do |*args|
  step %(I overwrite the file named "config.rb" with:), args[0] if args.any?
  step %(I run `middleman build --verbose`)
  step %(was successfully built)

  # FIXME: Causes test-suite to fail when run with all tests
  #        MM_ROOT env var is set when switched to directory,
  #        which causes tests to fail.
  #        Not sure, how else to build the rack app with properly loaded
  #        libraries, without CDing into the path.
  app = nil
  Dir.chdir(File.expand_path(expand_path('.'))) do
    app, = Rack::Builder.parse_file('config.ru')
  end

  Capybara.app = app.to_app
end
