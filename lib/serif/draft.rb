module Serif
class Draft < ContentFile
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
    save

    File.rename(path, full_published_path)

    # update the path since the file has now changed
    @path = Post.from_slug(site, slug).path
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