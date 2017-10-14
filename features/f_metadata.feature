Feature: Setting metadata from Child App

  Background:
    Given successfully built app is running at "real_world"

  Scenario: Default Metadata
    When  I go to "/test/metadata"
    Then  I should see metadata for "title" to be "Real World/Test App"
    And   I should see metadata for "description" to be empty
    And   I should see metadata for "html_description" to be empty
    And   I should see metadata for "routes" to be "[]"
    And   I should see metadata for "url" to be "/test"
    And   I should see metadata for "klass" to be "RealWorld::TestApp"

  Scenario: Allow access to metadata and setting title and description
    When  I go to "/api/metadata"
    Then the status code should be "200"
    And  I should see metadata for "title" to be "Awesome API"
    And  I should see metadata for "description" to have "## Awesome API v3"
    And  I should see metadata for "html_description" to have "<h2>Awesome API v3</h2>"

  Scenario: Set routes and arbitrary information as metadata
    When  I go to "/api/metadata"
    Then  I should see metadata for "arbitrary" to be "defined"
     And  I should see metadata for "routes" to have "#GET /ping"
