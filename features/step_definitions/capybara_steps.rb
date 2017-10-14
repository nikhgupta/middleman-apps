Then(/^I should see text "([^\"]*)"$/) do |text|
  expect(page).to have_text(text)
end
Then(/^I should not see text "([^\"]*)"$/) do |text|
  expect(page).to have_no_text(text)
end

Then(/^I should see metadata for "([^\"]*)" to be "([^\"]*)"$/) do |key, val|
  expect(page.body).to include("#{key} => #{val}")
end

Then(/^I should see metadata for "([^\"]*)" to have "([^\"]*)"$/) do |key, val|
  expect(page.body).to match(/^#{key} => .*#{Regexp.escape val}/)
end

Then(/^I should see metadata for "([^\"]*)" to be empty$/) do |key|
  expect(page.body).to match(/^#{key} =>\s*$/)
end
