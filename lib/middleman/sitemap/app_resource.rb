module Middleman
  module Sitemap
    # Base app resource that inherits from Sitemap Resource.
    #
    class AppResource < Resource
      def self.find_by_klass(klass, app)
        app.sitemap.resources.detect do |res|
          res.is_a?(self) && res.locals['klass'].name == klass.name
        end
      end

      def self.find_by_path(path, app)
        app.sitemap.resources.detect do |res|
          res.is_a?(self) && res.source_file.to_s == path.to_s
        end
      end

      def title
        locals['title'] || path.to_s.titleize
      end

      def routes
        locals['routes'] || []
      end

      def title=(str)
        data['title'] = str
        metadata[:locals]['title'] = str
      end

      def description=(str)
        str = str.to_s.gsub(/^#{str.scan(/^[ \t]+(?=\S)/).min}/, '')
        html = Tilt['markdown'].new { str }.render(self)
        metadata[:locals]['description'] = str
        metadata[:locals]['html_description'] = html
      end

      def update_locals(key, val)
        return send("#{key}=", val) if respond_to?("#{key}=")
        metadata[:locals][key.to_s] = val
      end

      def render(opts = {}, locs = {}, &block)
        md   = metadata
        locs = md[:locals].deep_merge(locs)
        opts = md[:options].deep_merge(opts)
        locs[:current_path] ||= destination_path

        layout  = "layouts/#{opts.delete(:layout)}"
        context = @app.template_context_class.new(@app, locs, opts)
        context.render(:middleman, layout, opts.merge(locals: locs), &block)
      end

      def method_missing(m, *a, &b)
        return locals[m.to_s] if locals.key?(m.to_s)
        super
      end
    end
  end
end
