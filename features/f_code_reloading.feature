Feature: Code reloading for child apps

  @mechanize @development
  Scenario: Allows reloading in development server
    Given a fixture app "real_world"
      And server is running in background
     When I go to "/child-app" on local server
     Then I should see "hello my world"
     When I overwrite the file named "apps/child_app.rb" with:
          """
          require 'middleman/apps/base'
          class RealWorld::ChildApp < ::Middleman::Apps::Base
            get '/' do
              "reloaded #{named} world"
            end
            def named; 'other'; end
          end
          """
      And I go to "/child-app" on local server
     Then I should see "reloaded other world"

  @mechanize @production
  Scenario: Do not allow reloading of apps in production
    Given a fixture app "real_world"
      And server is running in background
     When I go to "/child-app" on local server
     Then I should see "hello my world"
     When I overwrite the file named "apps/child_app.rb" with:
          """
          require 'middleman/apps/base'
          class RealWorld::ChildApp < ::Middleman::Apps::Base
            get '/' do
              'hello world\n' * n
            end
            def n; 2; end
          end
          """
      And I go to "/child-app" on local server
     Then I should see "hello my world"

  @mechanize @development
  Scenario: New child apps are loaded automatically
    Given a fixture app "real_world"
      And server is running in background
     When I go to "/unknown-app" on local server
     Then the status code should be "404"
      And I should see "File Not Found"
     When I write to "apps/unknown_app.rb" with:
          """
          require 'middleman/apps/base'
          class RealWorld::UnknownApp < ::Middleman::Apps::Base
            get '/' do
              "I am now!"
            end
          end
          """
      And I go to "/unknown-app" on local server
     Then I should see "I am now!"

  @mechanize @production
  Scenario: New child apps are NOT loaded automatically
    Given a fixture app "real_world"
      And server is running in background
     When I go to "/unknown-app" on local server
     Then the status code should be "404"
      And I should see "Not Found"
     When I write to "apps/unknown_app.rb" with:
          """
          require 'middleman/apps/base'
          class RealWorld::UnknownApp < ::Middleman::Apps::Base
            get '/' do
              "I am now!"
            end
          end
          """
      And I go to "/unknown-app" on local server
     Then the status code should be "404"
      And I should see "Not Found"

  @mechanize @development
  Scenario: Removing child apps removes them from server
    Given a fixture app "real_world"
      And server is running in background
     When I go to "/child-app" on local server
     Then I should see "hello my world"
     When I remove the file named "apps/child_app.rb"
      And I go to "/child-app" on local server
     Then the status code should be "404"
      And I should see "File Not Found"

  @mechanize @production
  Scenario: Removing child apps does NOT remove them from server
    Given a fixture app "real_world"
      And server is running in background
     When I go to "/child-app" on local server
     Then I should see "hello my world"
     When I remove the file named "apps/child_app.rb"
      And I go to "/child-app" on local server
     Then I should see "hello my world"
