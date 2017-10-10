Feature: 404 error pages using Rack and MiddlemanApps

  # Rack::NotFound's default response
  Scenario: Default 404 response from Built app
    Given a fixture app "simple-app"
      And app is running
     When I go to "/unknown-app"
     Then the status code should be "404"
      And I should see "Not found"

  # Use default 404 error page for `middleman-apps`:
  # Serve 404 pages from file: build/404.html
  Scenario: 404 response from Built app when `404.html` exists
    Given a fixture app "simple-app"
      And a file named "source/404.html.erb" with:
          """
          <h1><%= (400+4).to_s + ' - Not Found' %></h1>
          """
      And app is running
     When I go to "/unknown-app"
     Then the status code should be "404"
      And I should see "<h1>404 - Not Found</h1>"

  # Use custom error page for `middleman-apps`:
  Scenario: With a custom error page
    Given a fixture app "simple-app"
      And a file named "source/custom.html.erb" with:
          """
          <h2><%= 404 %> Custom Not Found!</h2>
          """
      And app is running with config:
          """
          activate :apps, not_found: "custom.html"
          """
    When I go to "/unknown-app"
    Then the status code should be "404"
    And  I should see "<h2>404 Custom Not Found!</h2>"

  # Use custom error page for `middleman-apps`:
  # Ensure that `build/404.html` is not being used for 404 pages now.
  Scenario: No default 404 with custom error page
    Given a fixture app "simple-app"
      And a file named "source/404.html.erb" with:
          """
          <h1>Not Found</h1>
          """
      And app is running with config:
          """
          activate :apps, not_found: "custom.html"
          """
    When I go to "/unknown-app"
    Then the status code should be "404"
    And  I should see "Not found"
