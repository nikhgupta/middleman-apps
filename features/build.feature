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

  Scenario: Running built inherited app
    Given a fixture app "complex-app"
    And   app is running with config:
          """
          activate :apps, namespace: :complex_app
          """
     When I go to "/"
     Then I should see "<h1>Middleman</h1>"
     When I go to "/child-app"
     Then I should see "hello my world"
     When I go to "/child-app/page/anystring"
     Then I should see "<h3>rendered partial</h3>"
      And I should see "<h3>via layout</h3>"
      And I should see "<h3>via page</h3>"
      And I should see "anystring"
