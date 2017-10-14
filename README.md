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

## Installation

If you're just getting started, install the `middleman` gem and generate
a new project:

```
gem install middleman
middleman init MY_PROJECT
```

If you already have a Middleman project: Add `gem "middleman-apps"`
to your `Gemfile` and run `bundle install`.

## Getting Started

To get started with this extension, you only need to place a rack app
inside `MM_ROOT/apps` directory. Now, run `middleman build` or 
`middleman server`, and your rack app will be mounted for you.

The app should be visible in `/__middleman/sitemap`, as well.

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
using these child apps/endpoints in production mode, e.g. via `puma`, 
`rackup`, etc.. Try running `rackup`, and visiting the above endpoint on 
that server.

## Features

Consider a real world example, where you have a Middleman website 
running at `/`. Now, everything is static at this point. Lets, provide 
a page on this website, which redirects the user to a random blog entry 
from the last year. Lets assume this isn't possible without Javascript, 
or maybe you need to do some server-side processing before you redirect.

Well, we can write down a succint Sinatra application that queries 
Middleman's sitemap in the realtime, and redirect to a random article 
from there. Let's call this a `child app`.

Using this extension, you can place this `child app` inside your 
Middleman directory, and have it mounted at a specific path, and add 
other niceties, and so on.

- Creates an `umbrella` rack-app that mounts Middleman to `/` and all 
  other child apps inside itseslf. You can run this umbrella application 
  in development mode using `middleman server`.
  
- A `config.ru` is generated for you, so that you can run this 
  `umbrella` application in production using `rackup`, `puma`, etc. What 
  you see in development is what you get in production (nearly).

- Use a specific `404` error page that is used across `middleman` 
  application and `child apps` in production mode.

- Automatic reloading of code for child apps in development mode.

- Specify `url` where a given `child-app` should be mounted.

- Use Middleman layouts in the HTML rendered by child apps. Requires 
  child apps to be inherited from `Middleman::Apps::Base`, which in turn 
  inherits from `Sinatra::Base`.

  Inheriting from this class, also, provides you with several other 
  goodies, such as specifying title and description for your child apps, 
  so that they can be listed on some page with some overview of what 
  they do. It is recommended to inherit from this class, when possible.

- Works well with `DirectoryIndexes`, and `AssetHash` extensions.

## Configuration

```
activate :apps,
  map: {},               # Mappings for custom URL and Class for child apps
  verbose: false,        # Display warnings if any when building main app
  not_found: "404.html", # Render this page for 404 errors, if it exists
  namespace: nil,        # Use a namespace for Class of a child app
  mount_path: '/',       # Prefix all child apps URLs with this path
  app_dir: 'apps'        # Child apps are placed in this directory.
```

### `not_found: '404.html'`

This option defines a custom HTML page to use for 404 errors. By
default, HTML from `404.html` is served if it exists. Otherwise,
a default 404 response is sent.

A warning is generated in `verbose` mode, if this file does not exist!
Set this option to `false`, if you prefer not to use a 404 page and
would rather stick with default 404 response from Rack.

At the moment, this page can not be shown in `development` mode, but 
will be used for missing URIs across the `umbrella` application in 
`production`.

### `verbose: false`

If true, display warnings such as non-existent 404 error page, and any
child apps that were ignored when starting server or building it.

### `namespace: nil`

Specify a global namespace to find child apps in. Look at `map` option
below for better clarification.

### `map: {}`

This option can be used to specify a custom URL endpoint for a specific
child app, or class name for your child app if different than
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

### `mount_path: /a/b/c/d`:

Prefix URL for child apps with the given string, such that a child app 
that was to be mounted on `/child-app`, will now be mounted at: 
`/a/b/c/d/child-app`.

### `app_dir: apps`:

Customize the name of the directory used to host all child apps.

## Middleman Layouts

Child apps can use Middleman layouts, if required. This is useful to 
keep a seamless appearance across the `umbrella` application.

To use Middleman layouts, inherit your child app from 
`Middleman::Apps::Base` and call `middleman_layout` with appropriate 
layout name, like this:

    require 'middleman/apps/base'

    class TestApp < Middleman::Apps::Base
      get '/' do
        middleman_layout :page, locals: { var: value }
      end
    end

The above call to `middleman layout` will try to render 
`source/layouts/page.erb` layout from Middleman and pass it specified 
options or locals.

## Listing child apps on a Middleman Page

    # in: source/apps.html.erb

    <section class="child-apps list">
      <h3 class="title">Available apps:</h3>
      <ul>
        <% apps_list.each_with_index do |app, i| %>
          <article>
          <h2 class="title"><%= link_to app.title, app.url %></h2>
          <p><%= app.html_description %></p>
          </article>
        <% end %>
      </ul>
    </section>

- `title`, `url`, and `routes` for the application are added on their 
  own.
- To overwrite `title`, or provide `description`, or any other arbitrary 
  metadata for your child app, you can make a call to `set_metadata(key, 
  val)` in your child app (must inherit from `Middleman::Apps::Base`). 
  
- Markdown should be provided to `description`, which will be used to 
  populate `html_description`.

- Call `metadata` in your child app to have a peek at all the variables 
  that can be accessed this way.

For example:

    require 'middleman/apps/base'

    class SomeApp < ::Middleman::Apps::Base
      get '/' do
        'hello'
      end

      post '/' do
        'done'
      end

      add_routes_to_metadata :get # only `get` routes in metadata
      set_metadata :title, 'Awesome Application'
      set_metadata :description, <<-MARKDOWN
        # Description for this Child application

        This will be added as a metadata property for this child app.
      MARKDOWN
    end

## Notes/Gotchas

- To setup `routes` metadata, call `add_routes_to_metadata` at the end 
  of your child app (after, actually, defining your routes).

- 404 error page is not shown in `development` mode, i.e. when running 
  `middleman server`. A default `File Not Found` message is shown in 
  this case, by Middleman.

- When `relative_assets` is activated, 404 errors on 
  `/deeper/pages/in/your/website` will have wrong assets, and layout for 
  404 pages may be inconsistent with the rest of the site in this case.

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
[Simple]: https://github.com/nikhgupta/middleman-apps/tree/master/fixtures/simple
