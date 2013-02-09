require "test_helper"

describe Serif::Site do
  subject do
    Serif::Site.new(testing_dir)
  end

  before(:each) do
    FileUtils.rm_rf(testing_dir("_site"))
  end

  describe "site generation" do
    it "uses the permalinks in the config file for site generation" do
      subject.generate
      File.exist?(testing_dir("_site/test-blog/sample-post.html")).should be_true
    end

    it "reads the layout header for a non-post file and uses the appropriate layout file" do
      subject.generate

      # check it actually got generated
      File.exist?(testing_dir("_site/page-alt-layout.html")).should be_true
      File.read("_site/page-alt-layout.html").lines.first.should =~ /<h1.+?>Alternate layout<\/h1>/
    end

    it "correctly handles file_digest calls" do
      subject.generate

      File.read("_site/file-digest-test.html").strip.should == "f8390232f0c354a871f9ba0ed306163c\n.f8390232f0c354a871f9ba0ed306163c"
    end

    context "for drafts with a publish: now header" do
      before :all do
        @time = Time.utc(2012, 12, 21, 15, 30, 00)

        draft = Serif::Draft.new(subject)
        draft.slug = "post-to-be-published-on-generate"
        draft.title = "Some draft title"
        draft.autopublish = true
        draft.save("some content")

        @post = Serif::Draft.from_slug(subject, draft.slug)
        @post.should_not be_nil

        # verifies that the header has actually been written to the file, since
        # we round-trip the save and load.
        @post.autopublish?.should be_true

        # Site#generate creates a backup of the site directory in /tmp
        # and uses a timestamp, which is now fixed across all tests,
        # so we have to remove it first.
        FileUtils.rm_rf("/tmp/_site.2012-12-21-15-30-00")

        Timecop.freeze(@time)
      end

      after :all do
        Timecop.return

        # the generate processes creates its own set of instances, so the
        # value of #path here would be stale if we were to call @post.path
        FileUtils.rm(Serif::Post.from_slug(subject, @post.slug).path)
      end

      it "places the file in the published posts folder" do
        subject.generate
        File.exist?(testing_dir("_site/test-blog/#{@post.slug}.html")).should be_true
      end

      it "marks the creation time as the current time" do
        subject.generate
        Serif::Post.from_slug(subject, @post.slug).created.should == @time
      end
    end
  end
end