module Serif
class MarkupRenderer < Redcarpet::Render::SmartyHTML
  def block_code(code, language)
    # bypass it all to avoid sticking highlighting markup on stuff with no language.
    #
    # note that we add a new line after the initial ``` but not before the closing
    # ``` because otherwise it introduces an extra \n.
    if !language
        simple_code = %Q{```\n#{code}```}
        renderer = Redcarpet::Markdown.new(Redcarpet::Render::SmartyHTML, fenced_code_blocks: true, tables: true)
        return renderer.render(simple_code).strip
    end

    out = Rouge.highlight(code, language, "html")
    out.sub!(/^(<pre class=\"highlight\">)/, '\1<code>')
    out.sub!(/<\/pre>\z/, "</code></pre>\n")

    out
  end
end
end
