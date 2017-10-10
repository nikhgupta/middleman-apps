Feature: 404 error pages for Child apps

  Scenario: Custom 404 response from child app
    Given a fixture app "complex-app"
      And a file named "source/custom.html.erb" with:
          """
          <h2><%= 404 %> Custom Not Found!</h2>
          """
      And app is running with config:
          """
          activate :apps, not_found: "custom.html", namespace: :complex_app
          """
    When I go to "/child-app"
    Then I should see "hello"
    When I go to "/child-app/unknown"
    Then the status code should be "404"
    And  I should see "<h2>404 Custom Not Found!</h2>"

