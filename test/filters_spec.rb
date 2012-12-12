require "test_helper"

describe Serif::Filters do
  subject do
    o = Object.new
    o.extend(Serif::Filters)
    o
  end

  describe "#strip" do
    it "calls strip on its argument" do
      double = double("")
      double.should_receive(:strip).once
      subject.strip(double)

      s = " foo  "
      subject.strip(s).should == s.strip
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
        subject.encode_uri_component(char).should == enc_char
      end
    end
  end

  describe "#xmlschema" do
    it "calls xmlschema on its input" do
      d = double("")
      d.should_receive(:xmlschema).once
      subject.xmlschema(d)

      subject.xmlschema(Time.parse("2012-01-01")).should == "2012-01-01T00:00:00+00:00"
      subject.xmlschema(Time.parse("2012-01-01").utc).should == "2012-01-01T00:00:00Z"
    end
  end

  describe "#markdown" do
    it "processes its input as markdown" do
      # bit of a stub test
      subject.markdown("# Hi!").should == "<h1>Hi!</h1>"
    end
  end
end