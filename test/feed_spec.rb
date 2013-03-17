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

    it "generates a file with .xml appended appended to the path, containing correct contents" do
      # deal with only the first post when generating
      posts = @site.posts
      @site.stub(:posts) { [posts.first] }
      capture_stdout { @site.generate }
      path = testing_dir("_site#{@site.config.feed["path"]}.xml")
      File.exist?(path).should be_true
      File.read(path).should == %q{<?xml version="1.0" encoding="utf-8"?>

<feed xmlns="http://www.w3.org/2005/Atom">
  <title>Test Feed</title>
  <link rel="self" type="application/atom+xml" href="http://test-blog.com/test-feed"/>
  <link rel="alternate" type="text/html" href="http://test-blog.com"/>
  <id>tag:test-blog.com,2013:random-unique-permanent-id</id>
  <updated>2400-01-01T00:00:00Z</updated>
  <author>
    <name>J. Smith</name>
    <uri>http://test-blog.com</uri>
  </author>
  
  <entry>
    <id>tag:test-blog.com,2400-01-01:final-post</id>
    <title type="html">Final post</title>
    <updated>2400-01-01T00:00:00Z</updated>
    <published>2400-01-01T00:00:00Z</published>
    <link href="/test-blog/final-post" rel="alternate" type="text/html"/>
    <content type="html">&lt;p&gt;The final post in the blog&lt;/p&gt;
</content>
  </entry>
  
</feed>
}
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