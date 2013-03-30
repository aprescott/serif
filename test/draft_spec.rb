require "test_helper"

describe Serif::Draft do
  before :all do
    @site = Serif::Site.new(testing_dir)
    D = Serif::Draft
    FileUtils.rm_rf(testing_dir("_trash"))
  end

  describe "#url" do
    it "uses the current time for its placeholder values" do
      d = D.new(@site)
      d.slug = "my-blar-blar"
      orig_headers = d.headers
      d.stub(:headers) { orig_headers.merge(:permalink => "/foo/:year/:month/:day/:title") }

      Timecop.freeze(Time.parse("2020-02-09")) do
        d.url.should == "/foo/2020/02/09/my-blar-blar"
      end
    end

    it "defaults to the config file's permalink value" do
      d = D.new(@site)
      d.slug = "gablarhgle"
      d.url.should == "/test-blog/gablarhgle"
    end

    it "uses its permalink header value" do
      d = D.new(@site)
      d.slug = "anything"
      d.stub(:headers) { { :permalink => "testage" } }
      d.url.should == "testage"
    end
  end

  describe ".rename" do
    it "moves the draft to a new file" do
      draft = D.new(@site)
      draft.slug = "test-draft"
      draft.title = "Some draft title"
      draft.save("some content")

      D.rename(@site, "test-draft", "foo-bar")
      d = D.from_slug(@site, "foo-bar")
      d.should_not be_nil
      File.exist?(testing_dir("_drafts/foo-bar")).should be_true

      d.delete!
    end

    it "raises if there is an existing draft" do
      draft = D.new(@site)
      draft.slug = "test-draft"
      draft.title = "Some draft title"
      draft.save("some content")

      draft2 = D.new(@site)
      draft2.slug = "test-draft-2"
      draft2.title = "Some draft title"
      draft2.save("some content")

      expect { D.rename(@site, draft2.slug, draft.slug) }.to raise_error

      draft.delete!
      draft2.delete!
    end
  end

  describe "#delete!" do
    it "moves the file to _trash" do
      draft = D.new(@site)
      draft.slug = "test-draft"
      draft.title = "Some draft title"
      draft.save("some content")
      draft.delete!
      Dir[testing_dir("_trash/*-test-draft")].length.should == 1
    end

    it "creates the _trash directory if it doesn't exist" do
      FileUtils.rm_rf(testing_dir("_trash"))

      draft = D.new(@site)
      draft.slug = "test-draft"
      draft.title = "Some draft title"
      draft.save("some content")
      draft.delete!

      File.exist?(testing_dir("_trash")).should be_true
    end
  end

  describe "publish!" do
    it "moves the file to the _posts directory" do
      draft = D.new(@site)
      draft.slug = "test-draft"
      draft.title = "Some draft title"
      draft.save("some content")
      draft.publish!

      published_path = testing_dir("_posts/#{Date.today.to_s}-#{draft.slug}")
      File.exist?(published_path).should be_true

      # clean up
      FileUtils.rm_f(published_path)
    end

    it "makes the post available in Site#posts and Site#to_liquid even straight after a generate" do
      draft = D.new(@site)
      draft.slug = "test-draft-to-go-into-liquid"
      draft.title = "Some draft title"
      draft.save("some content")
      published_path = testing_dir("_posts/#{Date.today.to_s}-#{draft.slug}")

      begin
        @site.generate
        @site.posts.first.slug.should_not == draft.slug
        @site.to_liquid["posts"].first.slug.should_not == draft.slug
        draft.publish!
        @site.generate
        @site.posts.first.slug.should == draft.slug
        @site.to_liquid["posts"].first.slug.should == draft.slug
      rescue
        # clean up
        FileUtils.rm_f(published_path)
      end
    end

    it "changes the #path to be _posts not _drafts" do
      draft = D.new(@site)
      draft.slug = "test-draft"
      draft.title = "Some draft title"
      draft.save("some content")
      draft.publish!

      draft.path.should == testing_dir("_posts/#{Date.today.to_s}-#{draft.slug}")
      draft.delete! # still deleteable, even though it's been moved
    end

    it "does not write out an autopublish header if autopublish? is true" do
      draft = D.new(@site)
      draft.slug = "autopublish-draft"
      draft.title = "Some draft title"
      draft.autopublish = true
      draft.save("some content")
      draft.publish!

      # check the header on the object has been removed
      draft.autopublish?.should be_false

      # check the actual file doesn't have the header
      Serif::Post.from_slug(@site, draft.slug).headers[:publish].should be_nil

      draft.delete!
    end
  end

  describe "#autopublish=" do
    it "sets the 'publish' header to 'now' if truthy assigned value" do
      draft = D.new(@site)
      draft.slug = "test-draft"
      draft.title = "Some draft title"
      draft.save("some content")
      draft.autopublish = true

      draft.headers[:publish].should == "now"

      draft.delete!
    end

    it "removes the 'publish' header entirely if falsey assigned value" do
      draft = D.new(@site)
      draft.slug = "test-draft"
      draft.title = "Some draft title"
      draft.save("some content")
      draft.autopublish = false

      draft.headers.key?(:publish).should be_false

      draft.delete!
    end

    it "carries its value through to #autopublish?" do
      draft = D.new(@site)
      draft.slug = "test-draft"
      draft.title = "Some draft title"
      draft.autopublish = false
      draft.autopublish?.should be_false

      draft.autopublish = true
      draft.autopublish?.should be_true

      draft.autopublish = false
      draft.autopublish?.should be_false
    end
  end

  describe "#autopublish?" do
    it "returns true if there is a 'publish: now' header, otherwise false" do
      draft = D.new(@site)
      draft.autopublish?.should be_false
      headers = draft.headers
      draft.stub(:headers) { headers.merge(:publish => "now") }
      draft.autopublish?.should be_true
    end

    it "ignores leading and trailing whitespace around the value of the 'publish' header" do
      draft = D.new(@site)
      draft.autopublish?.should be_false
      headers = draft.headers
      draft.stub(:headers) { headers.merge(:publish => " now  ") }
      draft.autopublish?.should be_true
    end
  end

  describe "#save" do
    it "saves the file to _drafts" do
      draft = D.new(@site)
      draft.slug = "test-draft"
      draft.title = "Some draft title"

      D.exist?(@site, draft.slug).should be_false
      File.exist?(testing_dir("_drafts/test-draft")).should be_false
      
      draft.save("some content")

      D.exist?(@site, draft.slug).should be_true
      File.exist?(testing_dir("_drafts/test-draft")).should be_true

      # clean up the file
      draft.delete!
    end
  end
end