Feature: 404 error pages with Middleman Preview Server

  Scenario: Fixed 404 response with Server
    Given a fixture app "simple-app"
    And the Server is running at "simple-app"
    When I go to "/unknown-app"
    Then the status code should be "404"
    And  I should see "<h1>File Not Found</h1>"
