RSpec.describe Serif::Filters do
  let(:input) { double }

  subject do
    o = Object.new
    o.extend(Serif::Filters)
    o
  end

  describe "#strip" do
    it "calls strip on its argument" do
      allow(input).to receive(:strip).and_return("result")

      expect(subject.strip(input)).to eq("result")
    end
  end

  describe "#encode_uri_component" do
    it "percent-encodes various characters for use in a URI" do
      {
        # ambiguous cases, tested here to ensure we're talking about ?query=params.
        # http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-core/29373
        " " => "+",
        "!" => "%21",
        "$" => "%24",
        "&" => "%26",
        "'" => "%27",
        "(" => "%28",
        ")" => "%29",
        "*" => "%2A",
        "+" => "%2B",
        "/" => "%2F",
        ":" => "%3A",
        ";" => "%3B",
        "=" => "%3D",
        "?" => "%3F",
        "@" => "%40",
        "[" => "%5B",
        "]" => "%5D",
        "~" => "%7E"
      }.each do |char, enc_char|
        expect(subject.encode_uri_component(char)).to eq(enc_char)
      end
    end

    it "returns an empty string on nil input" do
      expect(subject.encode_uri_component(nil)).to eq("")
    end
  end

  describe "#smarty" do
    it "runs the input through a smartypants processor" do
      expect(subject.smarty("Testing")).to eq("Testing")
      expect(subject.smarty("Testing's")).to eq("Testing&#8217;s")
      expect(subject.smarty(%q{"Testing" some "text's" input...})).to eq("&#8220;Testing&#8221; some &#8220;text&#8217;s&#8221; input&#8230;")
    end

    it "does not do any markdown processing" do
      expect(subject.smarty("# Heading")).to eq("# Heading")
      expect(subject.smarty("Testing `code blocks` input")).to eq("Testing `code blocks` input")
    end

    it "deals with HTML appropriately" do
      expect(subject.smarty("<p>Testing's <span>span</span> testing</p>")).to eq("<p>Testing&#8217;s <span>span</span> testing</p>")
    end
  end

  describe "#markdown" do
    it "converts the input to markdown" do
      allow(Serif::Markdown).to receive(:render).with(input).and_return("result")

      expect(subject.markdown(input)).to eq("result")
    end
  end

  describe "#xmlschema" do
    it "calls xmlschema on its input" do
      allow(input).to receive(:xmlschema).and_return("result")

      expect(subject.xmlschema(input)).to eq("result")
    end
  end
end
