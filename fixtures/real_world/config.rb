activate :apps, not_found: 'custom.html',
                namespace: 'RealWorld',
                map: {
                  test_app: 'test',
                  awesome_api: {
                    url: 'api',
                    class: 'OtherNamespace::AwesomeAPI'
                  }
                }, verbose: true
