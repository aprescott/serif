module Serif
  class Page
    attr_reader :site, :path

    def initialize(site, path)
      @site = site
      @path = path
    end

    def render
      template = Liquid::Template.parse(source.to_s)

      if layout_option == "none"
        return template.render!("site" => site, "page" => headers)
      end

      layout.render!(
        "site" => site,
        "page" => headers,
        "content" => template.render!("site" => site, "page" => headers)
      )
    end

    private

    def source
      @source ||= Redhead::String[File.read(path)]
    end

    def headers
      source.headers.to_h.map { |k, v| [k.to_s, v] }.to_h
    end

    def title
      headers["title"]
    end

    def layout_option
      headers["layout"] || "default"
    end

    def layout
      layout_file = site.source_path("_layouts", "#{layout_option}.html")

      Liquid::Template.parse(File.read(layout_file))
    end
  end
end
