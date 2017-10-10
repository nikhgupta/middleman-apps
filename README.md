## Middleman Apps [![Build](https://api.travis-ci.org/nikhgupta/middleman-apps.svg?branch=master)](https://travis-ci.org/nikhgupta/middleman-apps)

`middleman-apps` is an extension for the [Middleman] static site
generator that allows you to run truly dynamic pages within your static
site using Rack-compatible (e.g. Sinatra) based child apps.

You can create dynamic pages using this extension. Maybe you want to:

- Create simple APIs that can be consumed by your static app via AJAX
- Showcase Code snippets alongside your blog.
- Provide simple Demos of a tech writeup, etc.
- Display a dynamic Gallery of your most recent timeline from Flickr?
- ... suggest one? ...

The best way to get started with this extension is to have a look at the
various `features` in the test suite. There is a test for each feature
that exists for extension, such as:

- Mount Rack apps by, simply, placing them in `MM_ROOT/apps` directory.
- Allow running child apps in-tandem with the static (built) MM app, and
  wrap them both in a single `Rack::App`, which can be run with e.g.
  `rackup`.
- Use a specific `404` error page that is common across your static
  website, and child apps mounted using this extension.
- Discovery of mountable child apps and automatic mounting.
- Optionally, specify a URL where a child app should be mounted.
- Optionally, specify a Class name or namespace for the child app.
- Optionally, inherit from `Middleman::Apps::BaseApp` for helper methods
  and added goodies for your apps.

### Example

You can, e.g. create a simple JSON API endpoint at: `/base64-api/`
by creating a file named `apps/base64_api.rb` with:

```ruby
# config.rb
...
activate :apps
...

# apps/base64_api.rb
require 'sinatra'
class Base64Api < Sinatra::Base
  get '/decode/:str' do
    Base64.decode64(params['str'])
  end
  get '/encode/:str' do
    Base64.encode64(params['str'])
  end
end
```

Run/Build your Middleman site now, and visit: 
`/base64-api/encode/somestring`. Voila! It just works!

A `config.ru` is, also, generated for you, so that you can keep
using these dynamic pages/endpoints using `rackup`. Try running 
`rackup`, and visiting the above endpoint on that server instance.

## Installation

If you're just getting started, install the `middleman` gem and generate
a new project:

```
gem install middleman
middleman init MY_PROJECT
```

If you already have a Middleman project: Add `gem "middleman-apps"`
to your `Gemfile` and run `bundle install`.

## Configuration

```
activate :apps,
  map: {},               # Mappings for custom URL and Class for child apps
  verbose: false,        # Display warnings if any when building main app
  not_found: "404.html", # Render this page for 404 errors, if it exists
  namespace: nil         # By default, use a namespace for finding Class
                         # of a child app
```

A `config.ru` will be generated for you (if one does not exist already),
when you preview/build your MM site. Your child apps will be mounted in
both development (preview) mode (e.g. via `middleman server`) as well in
production (build) mode of MM (e.g. running the built app using `puma`
or `rackup`).

## Options

### `not_found: '404.html'`

This option defines a custom HTML page to use for 404 errors. By
default, HTML from `404.html` is served if it exists. Otherwise,
a default 404 response is sent.

A warning is generated in `verbose` mode, if this file does not exist!
Set this option to `false`, if you prefer not to use a 404 page and
would rather stick with default 404 response from Rack.

### `verbose: false`

If true, display warnings such as non-existent 404 error page, and any
child apps that were ignored when starting server in
development/production mode.

### `namespace: nil`

Specify a global namespace to find child apps in. Look at `map` option
below for better clarification.

### `map: {}`

This option can be used to specify a custom URL endpoint for a specific
child app, or different class name for your child app if different than
what is guessed (`str.classify.constantize`).

```ruby
activate :apps,
  namespace: 'DynamicPages',
  map: {
    test_app: 'test',
    awesome_api: {
      url: 'api',
      class: "Project::AwesomeAPI"
    }
  }
```

With the above configuration in place, here is what happens:

- class `DynamicPages::TestApp` should exist inside
  `MM_ROOT/apps/test_app.rb` file, and it will be mounted at: `/test`
  endpoint.

- class `Project::AwesomeAPI` should exist inside
  `MM_ROOT/apps/awesome_api.rb` file, and it will be mounted at: `/api`
  endpoint.

- If another child app `DynamicPages::OtherMiniProject` exists in:
  `MM_ROOT/apps/other_mini_project.rb`, it will be mounted at:
  `/other-mini-project` endpoint.

## Community

The official community forum is available at: http://forum.middlemanapp.com

## Bug Reports

Github Issues are used for managing bug reports and feature requests. If
you run into issues, please search the issues and submit new problems:
https://github.com/middleman/middleman-blog/issues

The best way to get quick responses to your issues and swift fixes to
your bugs is to submit detailed bug reports, include test cases and
respond to developer questions in a timely manner. Even better, if you
know Ruby, you can submit
[Pull Requests](https://help.github.com/articles/using-pull-requests)
containing Cucumber Features which describe how your feature should work
or exploit the bug you are submitting.

## How to Run Cucumber Tests

- Checkout Repository:
  `git clone https://github.com/nikhgupta/middleman-apps.git`

- Install Bundler: `gem install bundler`

- Run `bundle install` inside the project root to install the gem
  dependencies.

- Run test cases: `bundle exec rake test`

## Donate

[Click here to lend your support to Middleman](https://spacebox.io/s/4dXbHBorC3)

## License

Copyright (c) 2018 Nikhil Gupta. MIT Licensed, see [LICENSE] for details.

[middleman]: http://middlemanapp.com
[LICENSE]: https://github.com/nikhgupta/middleman-apps/blob/master/LICENSE.txt
