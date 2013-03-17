require "test_helper"

describe Serif::Config::ValidityChecker do
  before :each do
    @site = Serif::Site.new(testing_dir)
    @config = @site.config
  end

  describe ".valid?" do
    it "is true on the test config as-is" do
      capture_stdout { subject.valid?(@config).should be_true }
    end

    it "is false if there is no base URL" do
      @config.stub(:base_url) { nil }
      capture_stdout { subject.valid?(@config).should be_false }
    end

    it "is true if feeds are disabled without any other feed settings" do
      feed = @config.feed
      @config.stub(:feed) { { "enabled" => false } }
      capture_stdout { subject.valid?(@config).should be_true }
    end

    it "is false if the feed ID isn't as expected" do
      feed = @config.feed

      [nil, "foo:abcdefghj", "2013", "2013:", "2013:abcdefg "].each do |s|
        @config.stub(:feed) { feed.merge({ "permanent_unique_id" => s }) }
        capture_stdout { subject.valid?(@config).should be_false }
      end
    end
  end
end