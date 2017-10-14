Feature: Various options that can be provided to this extension

  Scenario: Allows namespacing applications
    Given successfully built app is running at "real_world"
    When I go to "/child-app"
    Then the status code should be "200"
    And  I should see "hello my world"

  Scenario: Ignores modular apps that have no direct mapping
    Given successfully built app is running at "real_world"
    When I go to "/ignored-app"
    Then the status code should be "404"

  Scenario: Allows specifying different mount URL for an app
    Given successfully built app is running at "real_world"
    When I go to "/test"
    Then the status code should be "200"
    And  I should see "fail"

  Scenario: Allows specifying URL path for application
    Given successfully built app is running at "real_world"
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

  Scenario: Allows specifying mount point for all child apps
    Given successfully built app is running at "mount_path"
    When I go to "/test-app?test=1"
    Then the status code should be "404"
    When I go to "/a/b/c/d/test-app?test=1"
    Then the status code should be "200"
    And  I should see "pass"
