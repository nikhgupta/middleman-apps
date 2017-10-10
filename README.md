## Middleman Apps

`middleman-apps` is an extension for the [Middleman] static site
generator that allows you to run truly dynamic pages within your static
site using Sinatra based modular apps.

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
activate :apps, not_found: "custom404.html"
```

A `config.ru` will be generated for you once you activate this extension.

You can, now, use `middleman server` for development mode, or `rackup`
for viewing your site in production/build mode.

Assume that, you have a middleman site with root at: `./site`. 
Any `rack` or `sinatra` app created inside `./site/apps/` directory will
be mounted and visible from both `middleman server` and `rackup` commands.

An app at `./site/apps/test_app.rb` will be mounted at: `/test-app` URL.

### Options

`not_found` option defines a custom HTML page to use for 404 errors. By
default, HTML from `404.html` is served if it exists. Otherwise,
a default 404 response is sent.

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
[LICENSE]: https://github.com/nikhgupta/middleman-apps/blob/master/LICENSE
