Feature: When Activating Middleman::Apps

  Scenario: Without `middleman-apps`
    Given a fixture app "simple"
    And a file named "config.rb" with:
      """
      """
    And the Server is running at "simple"
    When I go to "/"
    Then I should see "<h1>Middleman</h1>"
    When I go to "/test-app"
    Then the status code should be "404"
    And  I should see "<h1>File Not Found</h1>"

  Scenario: Without `middleman-apps` but with Rack
    Given a fixture app "simple"
    And a file named "config.rb" with:
      """
      require 'sinatra'
      require_relative 'apps/test_app'
      map("/test-app") { run Simple::TestApp }
      """
    And the Server is running at "simple"
    When I go to "/"
    Then I should see "<h1>Middleman</h1>"
    When I go to "/test-app"
    Then I should see "fail"
    When I go to "/test-app/?test=1"
    Then I should see "pass"

  Scenario: With `middleman-apps`
    Given the Server is running at "simple"
    When I go to "/"
    Then I should see "<h1>Middleman</h1>"
    When I go to "/test-app"
    Then I should see "fail"
    When I go to "/test-app/?test=1"
    Then I should see "pass"

  Scenario: Adds a `config.ru`
    Given a fixture app "simple"
    Then the file "config.ru" should not exist
    When the Server is running at "simple"
    Then the file "config.ru" should exist

  Scenario: Allows changing path to apps directory
    Given a fixture app "simple"
    And I move the file named "apps/test_app.rb" to "other/test_app.rb"
    And a file named "config.rb" with:
      """
      activate :apps, app_dir: 'other', namespace: 'Simple'
      """
    And the Server is running at "simple"
    When I go to "/test-app/?test=1"
    Then I should see "pass"

  @production @slow
  Scenario: Display list of child apps which were ignored
    Given a fixture app "simple"
      And I overwrite the file named "config.rb" with:
          """
          activate :apps, namespace: 'Simple', verbose: true
          """
      And I run `middleman build --verbose`
      And the aruba exit timeout is 4 seconds
      And I run `rackup -p 17283` in background
     Then the output should match:
          """
          Ignored child app:.*apps\/ignored_app\.rb
          """
     And  the output should not match:
          """
          Ignored child app:.*apps\/test_app\.rb
          """
