require "test_helper"

describe Serif::ContentFile do
  subject do
    Serif::Site.new(testing_dir)
  end

  describe "#basename" do
    it "is the basename of the path" do
      (subject.drafts + subject.posts).each do |content_file|
        content_file.basename.should == File.basename(content_file.path)
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
        draft.path.should_not be_nil
        post.should_not be_nil
        draft.basename.should == post.basename

        # NOTE! Time frozen!
        post.basename.should == "2013-04-03-foo"
      ensure
        Timecop.return
        FileUtils.rm(post.path)
      end
    end
  end

  describe "draft?" do
    it "is true if the file is in the _drafts directory" do
      subject.drafts.each do |d|
        d.draft?.should be_true
        d.published?.should be_false
      end

      d = subject.drafts.sample
      orig_path = d.path
      d.stub(:path) { orig_path.gsub(/^#{Regexp.quote(testing_dir("_drafts"))}/, testing_dir("_anything")) }
      d.draft?.should be_false
    end
  end

  describe "published?" do
    it "is true if the file is in the _posts directory" do
      subject.posts.each do |p|
        p.published?.should be_true
        p.draft?.should be_false
      end

      p = subject.posts.sample
      orig_path = p.path
      p.stub(:path) { orig_path.gsub(/^#{Regexp.quote(testing_dir("_posts"))}/, testing_dir("_anything")) }
      p.published?.should be_false
    end
  end

  describe "#title=" do
    it "sets the underlying header value to the assigned title" do
      (subject.drafts + subject.posts).each do |content_file|
        content_file.title = "foobar"
        content_file.headers[:title].should == "foobar"
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
          post.updated.to_i.should == (t + 30).to_i
        end
      ensure
        FileUtils.rm(post.path)
      end
    end
  end
end