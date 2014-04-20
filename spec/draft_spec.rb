require "spec_helper"

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
      allow(d).to receive(:headers) { orig_headers.merge(:permalink => "/foo/:year/:month/:day/:title") }

      Timecop.freeze(Time.parse("2020-02-09")) do
        expect(d.url).to eq("/foo/2020/02/09/my-blar-blar")
      end
    end

    it "can handle nil slug values" do
      d = D.new(@site)
      expect(d.slug).to be_nil
      orig_headers = d.headers
      allow(d).to receive(:headers) { orig_headers.merge(:permalink => "/foo/:year/:month/:day/:title") }

      Timecop.freeze(Time.parse("2020-02-09")) do
        expect(d.url).to eq("/foo/2020/02/09/")
      end
    end

    it "defaults to the config file's permalink value" do
      d = D.new(@site)
      d.slug = "gablarhgle"
      expect(d.url).to eq("/test-blog/gablarhgle")
    end

    it "uses its permalink header value" do
      d = D.new(@site)
      d.slug = "anything"
      allow(d).to receive(:headers) { { :permalink => "testage" } }
      expect(d.url).to eq("testage")
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
      expect(d).not_to be_nil
      expect(File.exist?(testing_dir("_drafts/foo-bar"))).to be_true

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
      expect(Dir[testing_dir("_trash/*-test-draft")].length).to eq(1)
    end

    it "creates the _trash directory if it doesn't exist" do
      FileUtils.rm_rf(testing_dir("_trash"))

      draft = D.new(@site)
      draft.slug = "test-draft"
      draft.title = "Some draft title"
      draft.save("some content")
      draft.delete!

      expect(File.exist?(testing_dir("_trash"))).to be_true
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
      expect(File.exist?(published_path)).to be_true

      # clean up
      FileUtils.rm_f(published_path)
    end

    it "creates the posts directory if it doens't already exist" do
      draft = D.new(@site)
      draft.slug = "test-draft"
      draft.title = "Some draft title"
      draft.save("some content")

      expect(FileUtils).to receive(:mkdir_p).with(testing_dir("_posts")).and_call_original

      begin
        draft.publish!
      ensure
        FileUtils.rm(draft.path)
      end
    end

    it "makes the post available in Site#posts and Site#to_liquid even straight after a generate" do
      draft = D.new(@site)
      draft.slug = "test-draft-to-go-into-liquid"
      draft.title = "Some draft title"
      draft.save("some content")
      published_path = testing_dir("_posts/#{Date.today.to_s}-#{draft.slug}")

      begin
        capture_stdout { @site.generate }
        expect(@site.posts.first.slug).not_to eq(draft.slug)
        expect(@site.to_liquid["posts"].first.slug).not_to eq(draft.slug)
        draft.publish!
        capture_stdout { @site.generate }
        expect(@site.posts.first.slug).to eq(draft.slug)
        expect(@site.to_liquid["posts"].first.slug).to eq(draft.slug)
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

      expect(draft.path).to eq(testing_dir("_posts/#{Date.today.to_s}-#{draft.slug}"))
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
      expect(draft.autopublish?).to be_false

      # check the actual file doesn't have the header
      expect(Serif::Post.new(@site, draft.path).headers[:publish]).to be_nil

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

      expect(draft.headers[:publish]).to eq("now")

      draft.delete!
    end

    it "removes the 'publish' header entirely if falsey assigned value" do
      draft = D.new(@site)
      draft.slug = "test-draft"
      draft.title = "Some draft title"
      draft.save("some content")
      draft.autopublish = false

      expect(draft.headers.key?(:publish)).to be_false

      draft.delete!
    end

    it "carries its value through to #autopublish?" do
      draft = D.new(@site)
      draft.slug = "test-draft"
      draft.title = "Some draft title"
      draft.autopublish = false
      expect(draft.autopublish?).to be_false

      draft.autopublish = true
      expect(draft.autopublish?).to be_true

      draft.autopublish = false
      expect(draft.autopublish?).to be_false
    end
  end

  describe "#autopublish?" do
    it "returns true if there is a 'publish: now' header, otherwise false" do
      draft = D.new(@site)
      expect(draft.autopublish?).to be_false
      headers = draft.headers
      allow(draft).to receive(:headers) { headers.merge(:publish => "now") }
      expect(draft.autopublish?).to be_true
    end

    it "ignores leading and trailing whitespace around the value of the 'publish' header" do
      draft = D.new(@site)
      expect(draft.autopublish?).to be_false
      headers = draft.headers
      allow(draft).to receive(:headers) { headers.merge(:publish => " now  ") }
      expect(draft.autopublish?).to be_true
    end
  end

  describe "#to_liquid" do
    it "contains the relevant keys" do
      liq = @site.drafts.sample.to_liquid

      ["title", "content", "slug", "type", "draft", "published", "url"].each do |e|
        expect(liq.key?(e)).to be_true
      end
    end

    context "for an initial draft" do
      it "works fine" do
        expect { Serif::Draft.new(@site).to_liquid }.to_not raise_error
      end
    end
  end

  describe "#save" do
    it "saves the file to _drafts" do
      draft = D.new(@site)
      draft.slug = "test-draft"
      draft.title = "Some draft title"

      expect(D.exist?(@site, draft.slug)).to be_false
      expect(File.exist?(testing_dir("_drafts/test-draft"))).to be_false

      draft.save("some content")

      expect(D.exist?(@site, draft.slug)).to be_true
      expect(File.exist?(testing_dir("_drafts/test-draft"))).to be_true

      # clean up the file
      draft.delete!
    end
  end
end
