Feature: Compatibility with other Extensions: RelativeAssets

  @production @javascript
  Scenario: Custom error page with RelativeAssets
    Given successfully built app is running at "relative_assets"
     When I go to "/unknown-app"
     Then the status code should be "404"
      And I should see text "404 - Not Found!"
      And I should not see text "Error"

  @production @javascript @wip
  Scenario: Custom error page with RelativeAssets
    Given successfully built app is running at "relative_assets"
     When I go to "/unknown-app/some/deep/nested/url"
     Then the status code should be "404"
      And I should see text "404 - Not Found!"
      And I should not see text "Error"
