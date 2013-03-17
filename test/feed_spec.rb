require "test_helper"

describe Serif::Feed do
  before :each do
    @site = Serif::Site.new(testing_dir)
  end

  describe ".generate" do
    it "is nil if feed generation is disabled" do
      @site.stub(:yaml) { { "enabled" => false } }
      capture_stdout { subject.generate(@site).should be_nil }
    end

    it "is nil if feed generation is enabled but there are no posts" do
      @site.config.feed["enabled"].should be_true
      @site.stub(:posts) { [] }
      capture_stdout { subject.generate(@site) }
    end

    it "defaults to a path of /feed if none is set in the config" do
      @site.config.feed["path"] = nil
    end

    it "generates a file with .xml appended appended to the path" do
      capture_stdout { @site.generate }
      File.exist?(testing_dir("_site#{@site.config.feed["path"]}.xml")).should be_true
    end

    it "generates a file at /feed.xml by default" do
      config = @site.config
      feed   = config.feed
      config.stub(:feed) { feed.merge("path" => nil) }
      capture_stdout { @site.generate }
      File.exist?(testing_dir("_site/feed.xml")).should be_true
    end
  end
end