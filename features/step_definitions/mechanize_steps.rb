Given(/^server is running in background$/) do
  if development?
    step %(I run `middleman server -p #{Capybara.server_port}` in background)
  elsif production?
    step %(I run `middleman build --clean`) ## trigger generation of config.ru
    step %(I run `rackup -p #{Capybara.server_port}` in background)
  else
    raise 'You must set @development or @production tag before using this step'
  end
  sleep 10

  # TODO: match partial output from background process in aruba?
  # step %(I wait for stdout to contain "View your site at")
end

When(/^I go to "([^\"]*)" on local server$/) do |path|
  sleep 5 # wait to ensure path has reloaded if required
  visit "http://#{Capybara.server_host}:#{Capybara.server_port}#{path}"
end
