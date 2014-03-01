require "spec_helper"

describe Serif::Site do
  subject do
    Serif::Site.new(testing_dir)
  end

  before(:each) do
    FileUtils.rm_rf(testing_dir("_site"))
  end

  describe "site generation" do
    it "raises PostConflictError if there are conflicts" do
      # not nil, the value is unimportant
      allow(subject).to receive(:conflicts) { [] }
      expect { capture_stdout { subject.generate } }.to raise_error(Serif::PostConflictError)
    end

    it "uses the permalinks in the config file for site generation" do
      capture_stdout { subject.generate }
      expect(File.exist?(testing_dir("_site/test-blog/sample-post.html"))).to be_true
    end

    it "reads the layout header for a non-post file and uses the appropriate layout file" do
      capture_stdout { subject.generate }

      # check it actually got generated
      expect(File.exist?(testing_dir("_site/page-alt-layout.html"))).to be_true
      expect(File.read("_site/page-alt-layout.html").lines.first).to match(/<h1.+?>Alternate layout<\/h1>/)
    end

    it "reads the layout header for a post file and uses the appropriate layout file" do
      capture_stdout { subject.generate }

      # check it actually got generated
      expect(File.exist?(testing_dir("_site/test-blog/post-with-custom-layout.html"))).to be_true
      expect(File.read("_site/test-blog/post-with-custom-layout.html").lines.first).to match(/<h1.+?>Alternate layout<\/h1>/)
    end

    it "supports a smarty filter" do
      capture_stdout { subject.generate }
      expect(File.read("_site/test-smarty-filter.html")).to match(/testing&rsquo;s for a &ldquo;heading&rsquo;s&rdquo; `with code` in it&hellip;/)
    end

    it "correctly handles file_digest calls" do
      capture_stdout { subject.generate }

      expect(File.read("_site/file-digest-test.html").strip).to eq("f8390232f0c354a871f9ba0ed306163c\n.f8390232f0c354a871f9ba0ed306163c")
    end

    it "makes the previous and next posts available" do
      capture_stdout { subject.generate }

      contents = File.read("_site/test-blog/sample-post.html")
      previous_title = contents[/^Previous post: .+?$/]
      next_title = contents[/^Next post: .+?$/]

      expect(previous_title).to be_nil
      expect(next_title).not_to be_nil
      expect(next_title[/(?<=: ).+/]).to eq("Second post")

      contents = File.read("_site/test-blog/final-post.html")
      previous_title = contents[/Previous post: .+?$/]
      next_title = contents[/Next post: .+?$/]

      expect(previous_title).not_to be_nil
      expect(next_title).to be_nil
      expect(previous_title[/(?<=: ).+/]).to eq("Penultimate post")
    end

    it "sets a draft_preview flag for preview urls" do
      preview_flag_pattern = /draftpreviewflagexists/

      capture_stdout { subject.generate }

      d = Serif::Draft.from_slug(subject, "sample-draft")
      preview_contents = File.read(testing_dir("_site/#{subject.private_url(d)}.html"))
      expect(preview_contents =~ preview_flag_pattern).to be_true

      # does not exist on live published pages
      expect(File.read(testing_dir("_site/test-blog/second-post.html")) =~ preview_flag_pattern).to be_false
    end

    it "sets a post_page flag for regular posts" do
      capture_stdout { subject.generate }
      d = Serif::Post.from_basename(subject, "2013-01-01-second-post")
      expect(d).not_to be_nil
      contents = File.read(testing_dir("_site#{d.url}.html"))

      # available to the post layout file
      expect(contents =~ /post_page flag set for template/).to be_true

      # available in the layout file itself
      expect(contents =~ /post_page flag set for layout/).to be_true

      # not set for regular pages
      expect(File.read(testing_dir("_site/index.html")) =~ /post_page flag set for template/).to be_false
      expect(File.read(testing_dir("_site/index.html")) =~ /post_page flag set for layout/).to be_false

      # not set for drafts
      d = Serif::Draft.from_slug(subject, "sample-draft")
      preview_contents = File.read(testing_dir("_site/#{subject.private_url(d)}.html"))
      expect(preview_contents =~ /post_page flag set for template/).to be_false
      expect(preview_contents =~ /post_page flag set for layout/).to be_false
    end

    it "creates draft preview files" do
      capture_stdout { subject.generate }

      expect(Dir.exist?(testing_dir("_site/drafts"))).to be_true
      expect(Dir[File.join(testing_dir("_site/drafts/*"))].size).to eq(subject.drafts.size)

      expect(Dir.exist?(testing_dir("_site/drafts/sample-draft"))).to be_true
      expect(Dir[File.join(testing_dir("_site/drafts/sample-draft"), "*.html")].size).to eq(1)

      d = Serif::Draft.from_slug(subject, "sample-draft")
      expect(subject.private_url(d)).not_to be_nil

      # absolute paths
      expect(subject.private_url(d) =~ /\A\/drafts\/#{d.slug}\/.*\z/).to be_true

      # 60 characters long (30 bytes as hex chars)
      expect(subject.private_url(d) =~ /\A\/drafts\/#{d.slug}\/[a-z0-9]{60}\z/).to be_true

      # does not create more than one
      capture_stdout { subject.generate }
      expect(Dir[File.join(testing_dir("_site/drafts/sample-draft"), "*.html")].size).to eq(1)
    end

    context "for posts with an update: now header" do
      around :each do |example|
        begin
          d = Serif::Draft.new(subject)
          d.slug = "post-to-be-auto-updated"
          d.title = "Testing title"
          d.save("# some content")
          d.publish!

          @temporary_post = Serif::Post.new(subject, d.path)
          @temporary_post.autoupdate = true
          @temporary_post.save

          example.run
        ensure
          FileUtils.rm(@temporary_post.path)
        end
      end

      it "sets the updated header to the current time" do
        t = Time.now + 30
        Timecop.freeze(t) do
          capture_stdout { subject.generate }
          expect(Serif::Post.from_basename(subject, @temporary_post.basename).updated.to_i).to eq(t.to_i)
        end
      end
    end

    context "for drafts with a publish: now header" do
      before :each do
        @time = Time.utc(2012, 12, 21, 15, 30, 00)

        draft = Serif::Draft.new(subject)
        draft.slug = "post-to-be-published-on-generate"
        draft.title = "Some draft title"
        draft.autopublish = true
        draft.save("some content")

        @post = Serif::Draft.from_slug(subject, draft.slug)
        expect(@post).not_to be_nil

        # verifies that the header has actually been written to the file, since
        # we round-trip the save and load.
        expect(@post.autopublish?).to be_true

        # Site#generate creates a backup of the site directory in /tmp
        # and uses a timestamp, which is now fixed across all tests,
        # so we have to remove it first.
        FileUtils.rm_rf("/tmp/_site.2012-12-21-15-30-00")

        Timecop.freeze(@time)
      end

      after :each do
        Timecop.return

        # the generate processes creates its own set of instances, and we're
        # publishing a draft marked as autopublish, so our @post instance
        # has a #path value which is for the draft, not for the newly published
        # post. thus, we need to clobber.
        FileUtils.rm(*Dir[testing_dir("_posts/*-#{@post.slug}")])
      end

      it "places the file in the published posts folder" do
        capture_stdout { subject.generate }
        expect(File.exist?(testing_dir("_site/test-blog/#{@post.slug}.html"))).to be_true
      end

      it "marks the creation time as the current time" do
        capture_stdout { subject.generate }
        expect(subject.posts.find { |p| p.slug == @post.slug }.created.to_i).to eq(@time.to_i)
      end
    end
  end
end