require "fileutils"

module Serif
  class Post < ContentFile
    def self.all(site)
      super(site, "_posts", self)
    end

    def slug
      @slug ||= File.basename(path).split("-")[3..-1].join("-")
    end

    def published?
      true
    end

    def url
      permalink_style = headers[:permalink] || site.config.permalink

      filename_parts = File.basename(path).split("-")

      parts = {
        "title" => slug,
        "year" => filename_parts[0],
        "month" => filename_parts[1],
        "day" => filename_parts[2]
      }

      Serif::Placeholder.substitute(permalink_style, parts)
    end

    def autoupdate?
      headers[:update].to_s.strip == "now"
    end

    def update!
      @source.headers.delete(:update)
      save
    end

    def to_liquid
      super.merge(
        "created" => created,
        "updated" => updated,
      )
    end

    def render(site, prev_post:, next_post:)
      template_variables = {
        "post" => self,
        "post_page" => true,
        "prev_post" => prev_post,
        "next_post" => next_post
      }

      layout.render!(
        "site" => site,
        "page" => { "title" => title },
        "post_page" => true,
        "content" => template.render!(template_variables)
      )
    end
  end
end
