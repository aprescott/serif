require "kramdown"
require "rouge"

module Serif
  class Markdown
    def self.render(markdown)
      options = {
        input: "GFM",
        auto_id_stripping: true,
        enable_coderay: false,
        hard_wrap: false,
        parse_block_html: false
      }
      Kramdown::Document.new(markdown, options).to_serif_custom
    end
  end
end

module Kramdown
  module Converter
    class SerifCustom < Html
      def convert_codeblock(el, indent)
        attr = el.attr.dup
        language = extract_code_language!(attr)

        if language
          %~<pre class="highlight"><code>#{Rouge.highlight(el.value, language, "html")}</code></pre>\n~
        else
          super
        end
      end
    end
  end
end
