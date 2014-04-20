require "spec_helper"

describe Serif::ContentFile do
  subject do
    Serif::Site.new(testing_dir)
  end

  describe "#basename" do
    it "is the basename of the path" do
      (subject.drafts + subject.posts).each do |content_file|
        expect(content_file.basename).to eq(File.basename(content_file.path))
      end

      draft = Serif::Draft.new(subject)
      draft.slug = "foo"
      draft.title = "foo"

      # NOTE! Freezing!
      Timecop.freeze(Time.parse("2013-04-03"))

      draft.save
      draft.publish!
      post = Serif::Post.new(subject, draft.path)

      begin
        expect(draft.path).not_to be_nil
        expect(post).not_to be_nil
        expect(draft.basename).to eq(post.basename)

        # NOTE! Time frozen!
        expect(post.basename).to eq("2013-04-03-foo")
      ensure
        Timecop.return
        FileUtils.rm(post.path)
      end
    end
  end

  describe "draft and published status" do
    it "can handle a nil path" do
      c = Serif::ContentFile.new(subject)
      expect(c.path).to be_nil
      expect(c.draft?).to be_true
      expect(c.published?).to be_false
    end
  end

  describe "draft?" do
    it "is true if the file is in the _drafts directory" do
      subject.drafts.each do |d|
        expect(d.draft?).to be_true
        expect(d.published?).to be_false
      end

      d = subject.drafts.sample
      orig_path = d.path
      allow(d).to receive(:path) { orig_path.gsub(/^#{Regexp.quote(testing_dir("_drafts"))}/, testing_dir("_anything")) }
      expect(d.draft?).to be_false
    end
  end

  describe "published?" do
    it "can handle a nil path" do
      d = Serif::Post.new(subject)
      expect(d.draft?).to be_true
      expect(d.published?).to be_false
    end

    it "is true if the file is in the _posts directory" do
      subject.posts.each do |p|
        expect(p.published?).to be_true
        expect(p.draft?).to be_false
      end

      p = subject.posts.sample
      orig_path = p.path
      allow(p).to receive(:path) { orig_path.gsub(/^#{Regexp.quote(testing_dir("_posts"))}/, testing_dir("_anything")) }
      expect(p.published?).to be_false
    end
  end

  describe "#title=" do
    it "sets the underlying header value to the assigned title" do
      (subject.drafts + subject.posts).each do |content_file|
        content_file.title = "foobar"
        expect(content_file.headers[:title]).to eq("foobar")
      end
    end
  end

  describe "#save(markdown)" do
    it "sets the underlying updated time value for posts" do
      draft = Serif::Draft.new(subject)
      draft.title = "Testing"
      draft.slug = "hi"

      begin
        draft.save("# Some content")
        draft.publish!

        post = Serif::Post.new(subject, draft.path)

        t = Time.now
        Timecop.freeze(t + 30) do
          post.save("# Heading content")
          expect(post.updated.to_i).to eq((t + 30).to_i)
        end
      ensure
        FileUtils.rm(post.path)
      end
    end
  end
end
