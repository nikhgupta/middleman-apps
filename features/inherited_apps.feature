Feature: Child apps inherited from Middleman::Apps::Base

  Scenario: 404 response is same as Middleman app
    Given a fixture app "complex-app"
      And app is running with config:
          """
          activate :apps, namespace: :complex_app
          """
    When I go to "/test-app"
    Then I should see "Not found"
    When I go to "/child-app"
    Then I should see "hello my world"
    When I go to "/child-app/unknown"
    Then the status code should be "404"
     And I should see "Not found"

  Scenario: Custom 404 response is same as Middleman app
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
    Then I should see "hello my world"
    When I go to "/child-app/unknown"
    Then the status code should be "404"
    And  I should see "<h2>404 Custom Not Found!</h2>"

  Scenario: Middleman layouts can be used with multiple renderers
    Given a fixture app "complex-app"
      And app is running with config:
          """
          activate :apps, namespace: :complex_app
          """
    When I go to "/child-app/test"
    Then I should see "h1 span {"
    And  I should see "opacity: 1; }"

  Scenario: Middleman template helpers can be used
    Given a fixture app "complex-app"
      And app is running with config:
          """
          activate :apps, namespace: :complex_app
          """
    When I go to "/child-app/page"
    Then I should see "<h3>rendered partial</h3>"
     And I should see "<h3>via layout</h3>"
     And I should see "testing.."
     And I should see "<h3>via page</h3>"
