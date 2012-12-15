require "test_helper"

describe Serif::MarkupRenderer do
  subject do
    Redcarpet::Markdown.new(Serif::MarkupRenderer, fenced_code_blocks: true)
  end

  it "renders language-free code blocks correctly" do
    subject.render(<<END_SOURCE).should == <<END_OUTPUT.chomp
foo

```
some code
```
END_SOURCE
<p>foo</p>
<pre><code>some code
</code></pre>
END_OUTPUT
  end

  it "renders code blocks with a language correctly" do
    subject.render(<<END_SOURCE).should == <<END_OUTPUT
foo

```ruby
foo
```
END_SOURCE
<p>foo</p>
<pre class="highlight"><code><span class="n">foo</span>
</code></pre>
END_OUTPUT
  end
end