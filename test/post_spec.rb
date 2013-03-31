require "test_helper"

describe Serif::Post do
  subject do
    Serif::Site.new(testing_dir)
  end

  before :each do
    @posts = subject.posts
  end

  around :each do |example|
    begin
      d = Serif::Draft.new(subject)
      d.slug = "foo-bar-bar-temp"
      d.title = "Testing title"
      d.save("# some content")
      d.publish!
      @temporary_post = Serif::Post.new(subject, d.path)

      example.run
    ensure
      FileUtils.rm(@temporary_post.path)
    end
  end

  describe "#from_basename" do
    it "is nil if there is nothing found" do
      Serif::Post.from_basename(subject, "eoijfwoifjweofej").should be_nil
    end

    it "takes full filename within _posts" do
      Serif::Post.from_basename(subject, @temporary_post.basename).path.should == @temporary_post.path
    end
  end

  it "uses the config file's permalink value" do
    @posts.all? { |p| p.url == "/test-blog/#{p.slug}" }.should be_true
  end

  describe "#inspect" do
    it "includes headers" do
      @posts.all? { |p| p.inspect.should include(p.headers.inspect) }
    end
  end

  describe "#autoupdate=" do
    it "sets the 'update' header to 'now' if truthy assigned value" do
      @temporary_post.autoupdate = true
      @temporary_post.headers[:update].should == "now"
    end

    it "removes the 'update' header entirely if falsey assigned value" do
      @temporary_post.autoupdate = false
      @temporary_post.headers.key?(:update).should be_false
    end

    it "marks the post as autoupdate? == true" do
      @temporary_post.autoupdate?.should be_false
      @temporary_post.autoupdate = true
      @temporary_post.autoupdate?.should be_true
    end
  end

  describe "#autoupdate?" do
    it "returns true if there is an update: now header" do
      @temporary_post.stub(:headers) { { :update => "foo" } }
      @temporary_post.autoupdate?.should be_false
      @temporary_post.stub(:headers) { { :update => "now" } }
      @temporary_post.autoupdate?.should be_true
    end

    it "is ignorant of whitespace in the update header value" do
      @temporary_post.stub(:headers) { { :update => "now" } }
      @temporary_post.autoupdate?.should be_true

      (1..3).each do |left|
        (1..3).each do |right|
          @temporary_post.stub(:headers) { { :update => "#{" " * left}now#{" " * right}"} }
          @temporary_post.autoupdate?.should be_true
        end
      end
    end
  end

  describe "#update!" do
    it "sets the updated header timestamp to the current time" do
      old_update_time = @temporary_post.updated
      t = Time.now + 50

      Timecop.freeze(t) do
        @temporary_post.update!
        @temporary_post.updated.should_not == old_update_time
        @temporary_post.updated.to_i.should == t.to_i
        @temporary_post.headers[:updated].to_i.should == t.to_i
      end
    end

    it "calls save and writes out the new timestamp value, without a publish: now header" do
      @temporary_post.should_receive(:save).once.and_call_original

      t = Time.now + 50
      Timecop.freeze(t) do
        @temporary_post.update!

        file_content = Redhead::String[File.read(@temporary_post.path)]
        Time.parse(file_content.headers[:updated].value).to_i.should == t.to_i
        file_content.headers[:publish].should be_nil
      end
    end

    it "marks the post as no longer auto-updating" do
      @temporary_post.autoupdate?.should be_false
      @temporary_post.autoupdate = true
      @temporary_post.autoupdate?.should be_true
      @temporary_post.update!
      @temporary_post.autoupdate?.should be_false
    end
  end

  describe "#to_liquid" do
    it "contains the relevant keys" do
      liq = subject.posts.sample.to_liquid

      ["title",
       "created",
       "updated",
       "content",
       "slug",
       "url",
       "type",
       "draft",
       "published",
       "basename"].each do |e|
        liq.key?(e).should be_true
      end
    end
  end
end