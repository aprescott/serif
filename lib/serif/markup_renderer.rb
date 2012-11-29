module Serif
class MarkupRenderer < Redcarpet::Render::SmartyHTML
  def block_code(code, language)
    # bypass it all to avoid sticking highlighting markup on stuff with no language.
    # 
    # note that we add a new line after the initial ``` but not before the closing
    # ``` because otherwise it introduces an extra \n.
    return Redcarpet::Markdown.new(Redcarpet::Render::SmartyHTML, fenced_code_blocks: true).render(p %Q{```
#{code}```}).strip unless language

    out = Pygments.highlight(code, lexer: language)

    # first, get rid of the div, since we want
    # to stick the class onto the <pre>, to stay
    # clean markup-wise.
    out.sub!(/^<div[^>]*>/, "")
    out.strip!
    out.sub!(/<\/div>\z/, "")
    
    out.sub!(/^<pre>/, "<pre#{" class=\"highlight\""}><code>")
    out.sub!(/<\/pre>\z/, "</code></pre>\n")
    
    out
  end
end
end