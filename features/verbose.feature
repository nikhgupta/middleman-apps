Feature: Verbose mode

  Scenario: Display list of child apps which were ignored
    Given a fixture app "complex-app"
      And I overwrite the file named "config.rb" with:
          """
          activate :apps, verbose: true
          """
      And I run `middleman build --verbose`
      And the aruba exit timeout is 4 seconds
      And I run `rackup -p 17283` in background
     Then the output should match:
          """
          Ignored child app:.*apps\/awesome_api\.rb
          """
     And  the output should match:
          """
          Ignored child app:.*apps\/test_app\.rb
          """
     And  the output should match:
          """
          Ignored child app:.*apps\/child_app\.rb
          """
