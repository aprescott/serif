require "test_helper"

describe Serif::ContentFile do
  subject do
    Serif::Site.new(testing_dir)
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

        post = Serif::Post.from_slug(subject, draft.slug)

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