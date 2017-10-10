Feature: Compatibility with other Extensions

  # Use custom error page for `middleman-apps`:
  # with Directory Indexes on - using `find_resource_by_path`
  Scenario: Custom error page with Directory Indexes
    Given a fixture app "simple-app"
      And a file named "source/custom.html.erb" with:
          """
          <h2><%= 404 %> Custom Not Found!</h2>
          """
      And app is running with config:
          """
          activate :directory_indexes
          activate :apps, not_found: "custom.html"
          """
    When I go to "/unknown-app"
    Then the status code should be "404"
    And  I should see "<h2>404 Custom Not Found!</h2>"

  # Use custom error page for `middleman-apps`:
  # with Directory Indexes on - using `find_resource_by_destination_path`
  Scenario: Custom error page with Directory Indexes
    Given a fixture app "simple-app"
      And a file named "source/custom.html.erb" with:
          """
          <h2><%= 404 %> Custom Not Found!</h2>
          """
      And app is running with config:
          """
          activate :directory_indexes
          activate :apps, not_found: "custom/index.html"
          """
    When I go to "/unknown-app"
    Then the status code should be "404"
    And  I should see "<h2>404 Custom Not Found!</h2>"

  # Use custom error page for `middleman-apps`:
  # with Directory Indexes on - using `find_resource_by_page_id`
  Scenario: Custom error page with Directory Indexes
    Given a fixture app "simple-app"
      And a file named "source/custom.html.erb" with:
          """
          <h2><%= 404 %> Custom Not Found!</h2>
          """
      And app is running with config:
          """
          activate :directory_indexes
          activate :apps, not_found: "custom"
          """
    When I go to "/unknown-app"
    Then the status code should be "404"
    And  I should see "<h2>404 Custom Not Found!</h2>"
