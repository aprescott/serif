require "cgi"
require "rubypants"
require "liquid"
require "time"
require "digest"

module Serif
  module Filters
    def strip(input)
      input.strip
    end

    def encode_uri_component(string)
      return "" unless string

      CGI.escape(string)
    end

    def smarty(text)
      RubyPants.new(text).to_html
    end

    def markdown(body)
      Serif::Markdown.render(body)
    end

    def xmlschema(input)
      input.xmlschema
    end
  end

  class FileDigest < Liquid::Tag
    DIGEST_CACHE = {}

    # file_digest "file.css" [prefix:.]
    Syntax = /^\s*(\S+)\s*(?:(prefix\s*:\s*\S+)\s*)?$/

    def initialize(tag_name, markup, tokens)
      super

      if markup =~ Syntax
        @path = $1

        if $2
          @prefix = $2.gsub(/\s*prefix\s*:\s*/, "")
        else
          @prefix = ""
        end
      else
        raise SyntaxError.new("Syntax error for file_digest")
      end
    end

    # Takes the given path and returns the MD5
    # hex digest of the file's contents.
    #
    # The path argument is first stripped, and any leading
    # "/" has no effect.
    def render(context)
      return "" unless ENV["ENV"] == "production"

      full_path = File.join(context["site"]["__directory"], @path.strip)

      return @prefix + DIGEST_CACHE[full_path] if DIGEST_CACHE[full_path]

      digest = Digest::MD5.hexdigest(File.read(full_path))
      DIGEST_CACHE[full_path] = digest

      @prefix + digest
    end
  end
end

Liquid::Template.register_filter(Serif::Filters)
Liquid::Template.register_tag("file_digest", Serif::FileDigest)
