Feature: Built app

  Scenario: Builds successfully
    Given a successfully built app at "simple-app"
    Then the file "config.ru" should exist
    And  the file "build/index.html" should exist
    And  the file "build/apps/test_app.rb" should not exist

  Scenario: Running built app
    Given a fixture app "simple-app"
    And   app is running with config:
          """
          activate :apps
          """
    When  I go to "/"
    Then  I should see "<h1>Middleman</h1>"
    When  I go to "/test-app"
    Then  I should see "fail"
    When  I go to "/test-app?test=1"
    Then  I should see "pass"
