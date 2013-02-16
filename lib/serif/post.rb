require "fileutils"

module Serif
class Post < ContentFile
  def self.dirname
    "_posts"
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

    output = permalink_style

    parts.each do |placeholder, value|
      output = output.gsub(Regexp.quote(":" + placeholder), value)
    end

    output
  end

  def self.all(site)
    files = Dir[File.join(site.directory, dirname, "*")].select { |f| File.file?(f) }.map { |f| File.expand_path(f) }
    files.map { |f| new(site, f) }
  end

  def self.from_slug(site, slug)
    all(site).find { |p| p.slug == slug }
  end

  def to_liquid
    h = {
      "title" => title,
      "created" => created,
      "updated" => updated,
      "content" => content,
      "slug" => slug,
      "url" => url,
      "type" => "post",
      "draft" => draft?,
      "published" => published?
    }

    headers.each do |key, value|
      h[key.to_s] = value
    end

    h
  end
end
end