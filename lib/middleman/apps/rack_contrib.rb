# `rack-contrib` depends on `rack` v1.4, which is quite outdated now, and also,
# limits us to Sinatra v1.4, while Sinatra v2.0 is out.
#
# Since, `middleman-apps` uses 2 tiny classes from `rack-contrib`, I copied them
# here to remove `rack-contrib` from dependency list.
#
# Once `rack-contrib` supports `rack` v2.0, we can switch back to using it,
# instead of this file.
#
# @todo
#   [MAYBE] Merge the two Rack apps below into a single concise Rack app?
module ::Rack

  # The Rack::TryStatic middleware delegates requests to Rack::Static middleware
  # trying to match a static file
  #
  # Examples
  #
  # use Rack::TryStatic,
  #   :root => "public",  # static files root dir
  #   :urls => %w[/],     # match all requests
  #   :try => ['.html', 'index.html', '/index.html'] # try these postfixes sequentially
  #
  #   uses same options as Rack::Static with extra :try option which is an array
  #   of postfixes to find desired file

  class TryStatic

    def initialize(app, options)
      @app = app
      @try = ['', *options[:try]]
      @static = ::Rack::Static.new(
        lambda { |_| [404, {}, []] },
        options)
    end

    def call(env)
      orig_path = env['PATH_INFO']
      found = nil
      @try.each do |path|
        resp = @static.call(env.merge!({'PATH_INFO' => orig_path + path}))
        break if !(403..405).include?(resp[0]) && found = resp
      end
      found or @app.call(env.merge!('PATH_INFO' => orig_path))
    end
  end

  # Rack::NotFound is a default endpoint. Optionally initialize with the
  # path to a custom 404 page, to override the standard response body.
  #
  # Examples:
  #
  # Serve default 404 response:
  #   run Rack::NotFound.new
  #
  # Serve a custom 404 page:
  #   run Rack::NotFound.new('path/to/your/404.html')

  class NotFound
    F = ::File

    def initialize(path = nil, content_type = 'text/html')
      if path.nil?
        @content = "Not found\n"
      else
        @content = F.read(path)
      end
      @length = @content.size.to_s

      @content_type = content_type
    end

    def call(env)
      [404, {'Content-Type' => @content_type, 'Content-Length' => @length}, [@content]]
    end
  end
end
