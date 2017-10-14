Feature: Compatibility with other Extensions: DirectoryIndex

  # Use custom error page for `middleman-apps`:
  # with Directory Indexes on - using `find_resource_by_path`
  Scenario: Custom error page with Directory Indexes
    Given a fixture app "dir_index"
      And a file named "source/error.html.erb" with:
          """
          <h2><%= 404 %> Custom Not Found!</h2>
          """
      And app is running
    When I go to "/unknown-app"
    Then the status code should be "404"
    And  I should see "<h2>404 Custom Not Found!</h2>"

  # Use custom error page for `middleman-apps`:
  # with Directory Indexes on - using `find_resource_by_destination_path`
  Scenario: Custom error page with Directory Indexes
    Given a fixture app "dir_index"
      And a file named "source/error.html.erb" with:
          """
          <h2><%= 404 %> Custom Not Found!</h2>
          """
      And I overwrite the file named "config.rb" with:
          """
          activate :directory_indexes
          activate :apps, not_found: "error/index.html"
          """
      And app is running
    When I go to "/unknown-app"
    Then the status code should be "404"
    And  I should see "<h2>404 Custom Not Found!</h2>"

  # Use custom error page for `middleman-apps`:
  # with Directory Indexes on - using `find_resource_by_page_id`
  Scenario: Custom error page with Directory Indexes
    Given a fixture app "dir_index"
      And a file named "source/error.html.erb" with:
          """
          <h2><%= 404 %> Custom Not Found!</h2>
          """
      And I overwrite the file named "config.rb" with:
          """
          activate :directory_indexes
          activate :apps, not_found: "error"
          """
      And app is running
    When I go to "/unknown-app"
    Then the status code should be "404"
    And  I should see "<h2>404 Custom Not Found!</h2>"
