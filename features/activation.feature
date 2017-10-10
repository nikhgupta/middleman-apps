Feature: Activating MiddlemanApps

  Scenario: Without `middleman-apps`
    Given a fixture app "simple-app"
    And a file named "config.rb" with:
      """
      """
    And the Server is running at "simple-app"
    When I go to "/"
    Then I should see "<h1>Middleman</h1>"
    When I go to "/test-app"
    Then the status code should be "404"
    And  I should see "<h1>File Not Found</h1>"

  Scenario: Without `middleman-apps` with Rack
    Given a fixture app "simple-app"
    And a file named "config.rb" with:
      """
      require 'sinatra'
      require_relative 'apps/test_app'
      map("/test-app") { run TestApp }
      """
    And the Server is running at "simple-app"
    When I go to "/"
    Then I should see "<h1>Middleman</h1>"
    When I go to "/test-app"
    Then I should see "fail"
    When I go to "/test-app/?test=1"
    Then I should see "pass"

  Scenario: With `middleman-apps`
    Given a fixture app "simple-app"
    And a file named "config.rb" with:
      """
      activate :apps
      """
    And the Server is running at "simple-app"
    When I go to "/"
    Then I should see "<h1>Middleman</h1>"
    When I go to "/test-app"
    Then I should see "fail"
    When I go to "/test-app/?test=1"
    Then I should see "pass"

  Scenario: Adds a `config.ru`
    Given a fixture app "simple-app"
    Then the file "config.ru" should not exist
    Given a file named "config.rb" with:
      """
      activate :apps
      """
    And the Server is running at "simple-app"
    Then the file "config.ru" should exist
