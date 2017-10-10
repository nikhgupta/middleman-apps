Feature: Built app

  # @debug
  Scenario: Builds successfully
    Given a successfully built app at "simple-app"
    Then the file "config.ru" should exist
    And  the file "build/index.html" should exist
    And  the file "build/apps/test_app.rb" should not exist

  Scenario: Running built app
    Given a successfully built app at "simple-app"
    And   app is running as a rack app
    When  I go to "/"
    Then  I should see "<h1>Middleman</h1>"
    When  I go to "/test-app"
    Then  I should see "fail"
    When  I go to "/test-app?test=1"
    Then  I should see "pass"
