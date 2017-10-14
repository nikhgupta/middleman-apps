Feature: 404 error pages with MiddlemanApps

  # Rack::NotFound's default response
  @production
  Scenario: Default 404 response from Built app
    Given successfully built app is running at "simple"
     When I go to "/unknown-app"
     Then the status code should be "404"
      And I should see "Not found"

  # Use default 404 error page for `middleman-apps`:
  # Serve 404 pages from file: build/404.html
  @production
  Scenario: 404 response from Built app when `404.html` exists
    Given a fixture app "simple"
      And a file named "source/404.html.erb" with:
          """
          <h1><%= (400+4).to_s + ' - Not Found' %></h1>
          """
      And app is running
     When I go to "/unknown-app"
     Then the status code should be "404"
      And I should see "<h1>404 - Not Found</h1>"

  # Use custom error page for `middleman-apps`:
  @production
  Scenario: With a custom error page
    Given a fixture app "real_world"
      And a file named "source/custom.html.erb" with:
          """
          <h2><%= 404 %> Custom Not Found!</h2>
          """
      And app is running
    When I go to "/unknown-app"
    Then the status code should be "404"
    And  I should see "<h2>404 Custom Not Found!</h2>"

  @development
  Scenario: Fixed 404 response with Server
   Given the Server is running at "simple"
    When I go to "/unknown-app"
    Then the status code should be "404"
     And I should see "<h1>File Not Found</h1>"
