Feature: Real world JSON API example

  Scenario: Allows namespacing applications
    Given a fixture app "complex-app"
      And app is running with config:
          """
          activate :apps, namespace: "ComplexApp::SomeNamespace"
          """
    When I go to "/test-app?test=1"
    Then the status code should be "200"
    And  I should see "pass"

  Scenario: Allows namespacing applications via underscored module path
    Given a fixture app "complex-app"
      And app is running with config:
          """
          activate :apps, namespace: "complex_app/some_namespace"
          """
    When I go to "/test-app?test=1"
    Then the status code should be "200"
    And  I should see "pass"

  Scenario: Ignores modular apps that have no direct mapping
    Given a fixture app "complex-app"
      And app is running with config:
          """
          activate :apps, namespace: "other_namespacee"
          """
    When I go to "/test-app?test=1"
    Then the status code should be "404"

  Scenario: Allows specifying Application Name
    Given a fixture app "complex-app"
      And app is running with config:
          """
          activate :apps, map: { awesome_api: "OtherNamespace::AwesomeAPI" }
          """
    When I go to "/awesome-api/ping"
    Then the status code should be "200"
    And  I should see "pong"

  Scenario: Allows specifying URL path for application
    Given a fixture app "complex-app"
      And app is running with config:
          """
          activate :apps,
            namespace: 'complex_app/some_namespace',
            map: {
              test_app: {
                url: 'test'
              },
              awesome_api: {
                url: 'api',
                namespace: "OtherNamespace::AwesomeAPI"
              }
            }
          """
    When I go to "/test-app?test=1"
    Then the status code should be "404"
    When I go to "/test?test=1"
    Then the status code should be "200"
    And  I should see "pass"
    When I go to "/awesome-api/ping"
    Then the status code should be "404"
    When I go to "/api/ping"
    Then the status code should be "200"
    And  I should see "pong"
