module Serif
class Draft < ContentFile
  attr_reader :autopublish

  def self.dirname
    "_drafts"
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

  # sets the autopublish flag to the given value.
  #
  # if the assigned value is truthy, the "publish" header
  # is set to "now", otherwise the header is removed.
  def autopublish=(value)
    @autopublish = value

    if value
      @source.headers[:publish] = "now"
    else
      @source.headers.delete(:publish)
    end
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
      "published" => published?
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