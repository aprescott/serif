module Serif
  class Draft < ContentFile
    def self.all(site)
      super(site, "_drafts", self)
    end

    def slug
      @slug ||= File.basename(path)
    end

    def published?
      false
    end

    def url
      permalink_style = headers[:permalink] || site.config.permalink

      parts = {
        "title" => slug.to_s,
        "year" => Time.now.year.to_s,
        "month" => Time.now.month.to_s.rjust(2, "0"),
        "day" => Time.now.day.to_s.rjust(2, "0")
      }

      Serif::Placeholder.substitute(permalink_style, parts)
    end

    def publish!
      publish_time = Time.now
      date = publish_time.strftime("%Y-%m-%d")

      FileUtils.mkdir_p(site.source_path("_posts"))

      published_filename = "#{date}-#{slug}"
      published_path = site.source_path("_posts/#{published_filename}")

      if File.exist?(published_path)
        raise "found a conflict when trying to publish #{published_filename}: a file with that name exists already"
      end

      @source.headers[:created] = publish_time.xmlschema
      @source.headers.delete(:publish)

      save

      FileUtils.mv(path, published_path)
    end

    def autopublish?
      headers[:publish].to_s.strip == "now"
    end

    def render(site)
      layout.render!(
        "site" => site,
        "draft_preview" => true,
        "page" => { "title" => title },
        "content" => template.render!("site" => site, "post" => self, "draft_preview" => true)
      )
    end
  end
end
