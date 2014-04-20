require "spec_helper"

describe Serif::Filters do
  subject do
    o = Object.new
    o.extend(Serif::Filters)
    o
  end

  describe "#strip" do
    it "calls strip on its argument" do
      double = double("")
      expect(double).to receive(:strip).once
      subject.strip(double)

      s = " foo  "
      expect(subject.strip(s)).to eq(s.strip)
    end
  end

  describe "#smarty" do
    it "runs the input through a SmartyPants processor" do
      expect(subject.smarty("Testing")).to eq("Testing")
      expect(subject.smarty("Testing's")).to eq("Testing&rsquo;s")
      expect(subject.smarty("\"Testing\" some \"text's\" input...")).to eq("&ldquo;Testing&rdquo; some &ldquo;text&rsquo;s&rdquo; input&hellip;")
    end

    it "does not do any markdown processing" do
      expect(subject.smarty("# Heading")).to eq("# Heading")
      expect(subject.smarty("Testing `code blocks` input")).to eq("Testing `code blocks` input")
    end

    it "deals with HTML appropriately" do
      expect(subject.smarty("<p>Testing's <span>span</span> testing</p>")).to eq("<p>Testing&rsquo;s <span>span</span> testing</p>")
    end
  end

  describe "#encode_uri_component" do
    it "percent-encodes various characters for use in a URI" do
      {
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

  describe "#xmlschema" do
    it "calls xmlschema on its input" do
      d = double("")
      expect(d).to receive(:xmlschema).once
      subject.xmlschema(d)

      t = Time.parse("2012-01-01")
      t_utc = Time.utc("2012-01-01")
      # -0400 => -04:00
      offset = t.strftime("%z").gsub(/(\d\d)\z/, ':\1')

      expect(subject.xmlschema(t)).to eq("2012-01-01T00:00:00#{offset}")
      expect(subject.xmlschema(t_utc)).to eq("2012-01-01T00:00:00Z")
    end
  end

  describe "#markdown" do
    it "processes its input as markdown" do
      # bit of a stub test
      expect(subject.markdown("# Hi!").strip).to eq("<h1>Hi!</h1>")
    end

    it "uses curly single quotes properly" do
      expect(subject.markdown("# something's test")).to include("something&rsquo;s")
    end
  end
end
