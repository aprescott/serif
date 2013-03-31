module Serif
class Draft < ContentFile
  attr_reader :autopublish

  def self.dirname
    "_drafts"
  end

  def self.rename(site, original_slug, new_slug)
    raise if File.exist?("#{site.directory}/#{dirname}/#{new_slug}")
    File.rename("#{site.directory}/#{dirname}/#{original_slug}", "#{site.directory}/#{dirname}/#{new_slug}")
  end

  # Returns the URL that would be used for this post if it were
  # to be published now.
  def url
    permalink_style = headers[:permalink] || site.config.permalink

    parts = {
      "title" => slug.to_s,
      "year" => Time.now.year.to_s,
      "month" => Time.now.month.to_s.rjust(2, "0"),
      "day" => Time.now.day.to_s.rjust(2, "0")
    }

    output = permalink_style

    parts.each do |placeholder, value|
      output = output.gsub(Regexp.quote(":" + placeholder), value)
    end

    output
  end

  def delete!
    FileUtils.mkdir_p("#{site.directory}/_trash")
    File.rename(@path, File.expand_path("#{site.directory}/_trash/#{Time.now.to_i}-#{slug}"))
  end

  def publish!
    publish_time = Time.now
    date = Time.now.strftime("%Y-%m-%d")
    filename = "#{date}-#{slug}"
    full_published_path = File.expand_path("#{site.directory}/#{Post.dirname}/#{filename}")

    raise "conflict, post exists already" if File.exist?(full_published_path)

    set_publish_time(publish_time)

    @source.headers.delete(:publish) if autopublish?

    save

    File.rename(path, full_published_path)

    # update the path since the file has now changed
    @path = Post.from_slug(site, slug).path
  end

  # if the assigned value is truthy, the "publish" header
  # is set to "now", otherwise the header is removed.
  def autopublish=(value)
    if value
      @source.headers[:publish] = "now"
    else
      @source.headers.delete(:publish)
    end

    headers_changed!
  end

  # Checks the value of the "publish" header, and returns
  # true if the value is "now", ignoring trailing and leading
  # whitespace. Returns false, otherwise.
  def autopublish?
    publish_header = headers[:publish]
    publish_header && publish_header.strip == "now"
  end

  def to_liquid
    h = {
      "title" => title,
      "content" => content,
      "slug" => slug,
      "type" => "draft",
      "draft" => draft?,
      "published" => published?,
      "url" => url
    }

    headers.each do |key, value|
      h[key] = value
    end

    h
  end

  def self.exist?(site, slug)
    all(site).any? { |d| d.slug == slug }
  end

  def self.all(site)
    files = Dir[File.join(site.directory, dirname, "*")].select { |f| File.file?(f) }.map { |f| File.expand_path(f) }
    files.map { |f| new(site, f) }
  end

  def self.from_slug(site, slug)
    path = File.expand_path(File.join(site.directory, dirname, slug))
    new(site, path)
  end
end
end