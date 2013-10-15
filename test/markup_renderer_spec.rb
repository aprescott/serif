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

  # NOTE: The output here is not the desired output.
  #
  # See vmg/redcarpet#57 and note that any filters that use this renderer
  # are tested elsewhere.
  it "renders quote marks properly" do
    subject.render(<<END_SOURCE).should == <<END_OUTPUT
This "very" sentence's structure "isn't" necessary.
END_SOURCE
<p>This &ldquo;very&rdquo; sentence&rsquo;s structure &ldquo;isn&rsquo;t&rdquo; necessary.</p>
END_OUTPUT
  end
end