module Middleman
  module Sitemap
    # Base app resource that inherits from Sitemap Resource.
    #
    class AppResource < Resource
      def self.find_by_klass(klass, app)
        app.sitemap.resources.detect do |res|
          res.is_a?(self) && res.locals[:klass].name == klass.name
        end
      end

      def self.find_by_path(path, app)
        app.sitemap.resources.detect do |res|
          res.is_a?(self) && res.source_file.to_s == path.to_s
        end
      end

      # Get class for this child app.
      #
      # @return [Class] class for the child app
      #
      def klass
        locals[:klass]
      end

      def title
        locals[:title] || path.to_s.titleize
      end

      def description
        str = locals[:description].to_s
        locals[:description] = str.gsub(/^#{str.scan(/^[ \t]+(?=\S)/).min}/, '')
      end

      def update_locals(key, val)
        locals[key.to_sym] = val
      end

      def routes
        locals[:routes] || []
      end

      def html_description
        return locals[:html_description] if locals[:html_description]
        html = Tilt['markdown'].new { description }.render(self)
        locals[:html_description] = html
      end

      def render(opts = {}, locs = {})
        md   = metadata
        locs = md[:locals].deep_merge(locs)
        opts = md[:options].deep_merge(opts)
        locs[:current_path] ||= destination_path

        layout  = "layouts/#{opts.delete(:layout)}"
        context = @app.template_context_class.new(@app, locs, opts)
        context.render :middleman, layout, opts.merge(locals: locs)
      end
    end
  end
end
