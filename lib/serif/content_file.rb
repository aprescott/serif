require "time"
require "redhead"

module Serif
  class ContentFile
    attr_reader :path, :site

    def self.all(site, dirname, klass)
      Dir[site.source_path(dirname, "*")].select do |f|
        File.file?(f)
      end.map do |f|
        File.expand_path(f)
      end.map do |f|
        klass.new(site, f)
      end
    end

    def initialize(site, path)
      unless site && path
        raise ArgumentError, "must provide both site and path"
      end

      @site = site
      @path = path

      load_source
    end

    def draft?
      !published?
    end

    def title
      headers[:title]
    end

    def content
      @source.to_s
    end

    def created
      return nil unless headers[:created]

      headers[:created].utc
    end

    def updated
      time = headers[:updated] || created
      return nil unless time

      time.utc
    end

    def headers
      @cached_headers ||= @source.headers.to_h.map do |key, value|
        if key == :created || key == :updated
          value = Time.parse(value)
        end

        [key, value]
      end.to_h
    end

    def save
      set_updated_time(Time.now)

      File.open(path, "w") do |f|
        f.puts %Q{#{@source.headers.to_s}\n\n#{@source.to_s}}.strip
      end

      load_source
    end

    def to_liquid
      headers.map { |k, v| [k.to_s, v] }.to_h.merge(
        "content" => content,
        "slug" => slug,
        "url" => url,
        "draft" => draft?,
        "published" => published?
      )
    end

    protected

    def set_updated_time(time)
      @source.headers[:updated] = time.xmlschema
      headers_changed!
    end

    def headers_changed!
      @cached_headers = nil
    end

    private

    def load_source
      source = File.read(path).gsub(/\r?\n/, "\n")
      source.force_encoding("UTF-8")
      @source = Redhead::String[source]
      headers_changed!
    end

    def layout
      Liquid::Template.parse(File.read(site.source_path("_layouts", "#{headers[:layout] || "default"}.html")))
    end

    def template
      Liquid::Template.parse(File.read(site.source_path("_templates/post.html")))
    end
  end
end
