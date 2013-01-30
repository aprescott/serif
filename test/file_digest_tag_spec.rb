require "test_helper"

describe Serif::FileDigest do
  def file_digest(markup)
    Serif::FileDigest.new("file_digest", markup, "no tokens needed")
  end

  before :all do
    @original_env = ENV["ENV"]
    ENV["ENV"] = "production"
  end

  after :all do
    ENV["ENV"] = @original_env
  end

  before :each do
    site = Serif::Site.new(testing_dir)
    @context = { "site" => { "directory" => site.directory }}
  end

  describe "#render" do
    it "returns the md5 hex digest of the finally deployed site path" do
      file_digest("test-stylesheet.css").render(@context).should == "f8390232f0c354a871f9ba0ed306163c"
    end

    it "ignores leading slashes" do
      file_digest("/test-stylesheet.css").render(@context).should == "f8390232f0c354a871f9ba0ed306163c"
    end

    it "ignores surrounding whitespace" do
      file_digest("             test-stylesheet.css      ").render(@context).should == "f8390232f0c354a871f9ba0ed306163c"
    end

    it "includes a prefix if one is specified" do
      file_digest("test-stylesheet.css prefix:.").render(@context).should == ".f8390232f0c354a871f9ba0ed306163c"
    end
  end
end