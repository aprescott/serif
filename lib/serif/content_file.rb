#
# ContentFile represents a file on the filesystem
# which contains the contents of a post, be it in
# draft form or otherwise.
#
# A ContentFile can determine its type based on
# the presence or absence of a "published"
# timestamp value.
#

module Serif
class ContentFile
  attr_reader :path, :slug, :site

  def initialize(site, path = nil)
    @site = site
    @path = path

    if @path
      # we have to parse out the source first so that we get necessary
      # metadata like published vs. draft.
      load_source

      dirname = File.basename(File.dirname(@path))
      basename = File.basename(@path)
      @slug = draft? ? basename : basename.split("-")[3..-1].join("-")
    end
  end

  def slug=(str)
    @slug = str

    # if we're adding a slug and there's no path yet, then create the path.
    # this will run for new drafts

    if !@path
      @path = File.expand_path("#{self.class.dirname}/#{@slug}")
    end
  end

  def title
    return nil if new?
    headers[:title]
  end

  def title=(new_title)
    if new?
      @source = Redhead::String["title: #{new_title}\n\n"]
    else
      @source.headers[:title] = new_title
    end
  end
  
  def modified
    File.mtime(@path)
  end

  def draft?
    !published?
  end

  def published?
    headers.key?(:created)
  end
  
  def content(include_headers = false)
    include_headers ? "#{raw_headers}\n\n#{@source.to_s}" : @source.to_s
  end
  
  def new?
    !@source
  end

  def raw_headers
    @source.headers.to_s
  end

  def created
    return nil if new?
    headers[:created].utc
  end

  def updated
    return nil if new?
    (headers[:updated] || created).utc
  end
  
  def headers
    return {} unless @source

    headers = @source.headers
    converted_headers = {}

    headers.each do |header|
      key, value = header.key, header.value

      if key == :created || key == :updated
        value = Time.parse(value)
      end
      
      converted_headers[key] = value
    end

    converted_headers
  end

  def self.rename(original_slug, new_slug)
    raise if File.exist?("#{dirname}/#{new_slug}")
    File.rename("#{dirname}/#{original_slug}", "#{dirname}/#{new_slug}")
  end

  def save(markdown = nil)
    markdown ||= content if !new?
    
    save_path = path || "#{self.class.dirname}/#{@slug}"
    File.open(save_path, "w") do |f|
      f.puts %Q{#{raw_headers}

#{markdown}}.strip
    end

    # after every save, ensure we've re-loaded the saved content
    load_source

    true # always return true for now
  end
  
  def [](header)
    h = headers[header]
    if h
      h
    else
      raise "no such header #{header}"
    end
  end
    
  def inspect
    %Q{<#{self.class} #{headers.inspect}>}
  end
  
  def self.all
    Post.all + Draft.all
  end

  protected

  def set_publish_time(time)
    @source.headers[:created] = time.xmlschema
  end

  def set_updated_time(time)
    @source.headers[:updated] = time.xmlschema
  end

  private

  def load_source
    source = File.read(path).gsub(/\r?\n/, "\n")
    source.force_encoding("UTF-8")
    @source = Redhead::String[source]
  end
end
end