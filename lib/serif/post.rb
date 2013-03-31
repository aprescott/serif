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

  # if the assigned value is truthy, the "update" header
  # is set to "now", otherwise the header is removed.
  def autoupdate=(value)
    if value
      @source.headers[:update] = "now"
    else
      @source.headers.delete(:update)
    end

    headers_changed!
  end

  # returns true if the post has been marked as needing a
  # new updated timestamp header.
  #
  # this is based on the presence of an "update: now" header.
  def autoupdate?
    update_header = headers[:update]
    update_header && update_header.strip == "now"
  end

  # Updates the updated timestamp and saves the contents.
  #
  # If there is an "update" header (see autoupdate?), it is deleted.
  def update!
    @source.headers.delete(:update)
    set_updated_time(Time.now)
    save
  end

  def self.all(site)
    files = Dir[File.join(site.directory, dirname, "*")].select { |f| File.file?(f) }.map { |f| File.expand_path(f) }
    files.map { |f| new(site, f) }
  end

  def self.from_basename(site, filename)
    all(site).find { |p| p.basename == filename }
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
      "published" => published?,
      "basename" => basename
    }

    headers.each do |key, value|
      h[key.to_s] = value
    end

    h
  end
end
end