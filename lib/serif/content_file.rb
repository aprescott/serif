#
# ContentFile represents a file on the filesystem
# which contains the contents of a post, be it in
# draft form or otherwise.
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

    @path ||= File.expand_path("#{site.directory}/#{self.class.dirname}/#{@slug}")
  end

  def title
    return nil if !@source
    headers[:title]
  end

  def title=(new_title)
    if !@source
      @source = Redhead::String["title: #{new_title}\n\n"]
    else
      @source.headers[:title] = new_title
    end

    @cached_headers = nil
  end
  
  def draft?
    !published?
  end

  def published?
    headers.key?(:created)
  end
  
  def content(include_headers = false)
    include_headers ? "#{@source.headers.to_s}\n\n#{@source.to_s}" : @source.to_s
  end

  def created
    return nil if !@source
    headers[:created].utc
  end

  def updated
    return nil if !@source
    (headers[:updated] || created).utc
  end
  
  def headers
    return @cached_headers if @cached_headers

    return (@cached_headers = {}) unless @source

    headers = @source.headers
    converted_headers = {}

    headers.each do |header|
      key, value = header.key, header.value

      if key == :created || key == :updated
        value = Time.parse(value)
      end
      
      converted_headers[key] = value
    end

    @cached_headers = converted_headers
  end

  def save(markdown = nil)
    markdown ||= content if @source
    
    save_path = path || "#{self.class.dirname}/#{@slug}"

    # TODO: when a draft is being saved, it will call set_publish_time
    # and then the #save call will execute this line, which will mean
    # there is a very, very slight difference (fraction of a second)
    # between the update time of a brand new published post and the
    # creation time.
    set_updated_time(Time.now)
    
    File.open(save_path, "w") do |f|
      f.puts %Q{#{@source.headers.to_s}

#{markdown}}.strip
    end

    # after every save, ensure we've re-loaded the saved content
    load_source

    true # always return true for now
  end
    
  def inspect
    %Q{<#{self.class} #{headers.inspect}>}
  end
  
  protected

  def set_publish_time(time)
    @source.headers[:created] = time.xmlschema
    headers_changed!
  end

  def set_updated_time(time)
    @source.headers[:updated] = time.xmlschema
    headers_changed!
  end

  # Invalidates the cached headers entirely.
  #
  # Any methods which alter headers should call this.
  def headers_changed!
    @cached_headers = nil
  end

  private

  def load_source
    source = File.read(path).gsub(/\r?\n/, "\n")
    source.force_encoding("UTF-8")
    @source = Redhead::String[source]
    @cached_headers = nil
  end
end
end