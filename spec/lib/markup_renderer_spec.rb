RSpec.describe Serif::Markdown do
  subject { Serif::Markdown }

  it "renders language-free code blocks correctly" do
    expect(subject.render(<<END_SOURCE)).to eq(<<END_OUTPUT)
foo

```
some code
```

bar
END_SOURCE
<p>foo</p>

<pre><code>some code
</code></pre>

<p>bar</p>
END_OUTPUT
  end

  it "renders code blocks with a language correctly" do
    expect(subject.render(<<END_SOURCE)).to eq(<<END_OUTPUT)
foo

```ruby
foo
```

bar
END_SOURCE
<p>foo</p>

<pre class="highlight"><code><span class="n">foo</span>
</code></pre>

<p>bar</p>
END_OUTPUT
  end

  it "renders quote marks properly" do
    expect(subject.render(<<END_SOURCE)).to eq(<<END_OUTPUT)
This "very" sentence's structure "isn't" necessary.
END_SOURCE
<p>This “very” sentence’s structure “isn’t” necessary.</p>
END_OUTPUT
  end
end
