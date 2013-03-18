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
      capture_stdout { subject.generate }
      File.exist?(testing_dir("_site/test-blog/sample-post.html")).should be_true
    end

    it "reads the layout header for a non-post file and uses the appropriate layout file" do
      capture_stdout { subject.generate }

      # check it actually got generated
      File.exist?(testing_dir("_site/page-alt-layout.html")).should be_true
      File.read("_site/page-alt-layout.html").lines.first.should =~ /<h1.+?>Alternate layout<\/h1>/
    end

    it "reads the layout header for a post file and uses the appropriate layout file" do
      capture_stdout { subject.generate }

      # check it actually got generated
      File.exist?(testing_dir("_site/test-blog/post-with-custom-layout.html")).should be_true
      File.read("_site/test-blog/post-with-custom-layout.html").lines.first.should =~ /<h1.+?>Alternate layout<\/h1>/
    end

    it "supports a smarty filter" do
      capture_stdout { subject.generate }
      File.read("_site/test-smarty-filter.html").should =~ /testing&rsquo;s for a &ldquo;heading&rsquo;s&rdquo; `with code` in it&hellip;/
    end

    it "correctly handles file_digest calls" do
      capture_stdout { subject.generate }

      File.read("_site/file-digest-test.html").strip.should == "f8390232f0c354a871f9ba0ed306163c\n.f8390232f0c354a871f9ba0ed306163c"
    end

    it "makes the previous and next posts available" do
      capture_stdout { subject.generate }

      contents = File.read("_site/test-blog/sample-post.html")
      previous_title = contents[/^Previous post: .+?$/]
      next_title = contents[/^Next post: .+?$/]

      previous_title.should be_nil
      next_title.should_not be_nil
      next_title[/(?<=: ).+/].should == "Second post"

      contents = File.read("_site/test-blog/final-post.html")
      previous_title = contents[/Previous post: .+?$/]
      next_title = contents[/Next post: .+?$/]
      
      previous_title.should_not be_nil
      next_title.should be_nil
      previous_title[/(?<=: ).+/].should == "Penultimate post"
    end

    it "sets a draft_preview flag for preview urls" do
      preview_flag_pattern = /draftpreviewflagexists/

      capture_stdout { subject.generate }

      d = Serif::Draft.from_slug(subject, "sample-draft")
      preview_contents = File.read(testing_dir("_site/#{subject.private_url(d)}.html"))
      preview_contents =~ preview_flag_pattern

      # does not exist on live published pages
      (File.read(testing_dir("_site/test-blog/second-post.html")) =~ preview_flag_pattern).should be_false
    end

    it "creates draft preview files" do
      capture_stdout { subject.generate }

      Dir.exist?(testing_dir("_site/drafts")).should be_true
      Dir[File.join(testing_dir("_site/drafts/*"))].size.should == subject.drafts.size

      Dir.exist?(testing_dir("_site/drafts/sample-draft")).should be_true
      Dir[File.join(testing_dir("_site/drafts/sample-draft"), "*.html")].size.should == 1

      d = Serif::Draft.from_slug(subject, "sample-draft")
      subject.private_url(d).should_not be_nil

      # absolute paths
      (subject.private_url(d) =~ /\A\/drafts\/#{d.slug}\/.*\z/).should be_true

      # 60 characters long (30 bytes as hex chars)
      (subject.private_url(d) =~ /\A\/drafts\/#{d.slug}\/[a-z0-9]{60}\z/).should be_true

      # does not create more than one
      capture_stdout { subject.generate }
      Dir[File.join(testing_dir("_site/drafts/sample-draft"), "*.html")].size.should == 1
    end

    context "for posts with an update: now header" do
      it "does what it needs to"
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
        capture_stdout { subject.generate }
        File.exist?(testing_dir("_site/test-blog/#{@post.slug}.html")).should be_true
      end

      it "marks the creation time as the current time" do
        capture_stdout { subject.generate }
        Serif::Post.from_slug(subject, @post.slug).created.should == @time
      end
    end
  end
end