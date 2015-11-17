RSpec.describe Serif::Post do
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
      expect(Serif::Post.from_basename(subject, "eoijfwoifjweofej")).to be_nil
    end

    it "takes full filename within _posts" do
      expect(Serif::Post.from_basename(subject, @temporary_post.basename).path).to eq(@temporary_post.path)
    end
  end

  it "uses the config file's permalink value" do
    expect(@posts.all? { |p| p.url == "/test-blog/#{p.slug}" }).to be_truthy
  end

  describe "#inspect" do
    it "includes headers" do
      @posts.all? { |p| expect(p.inspect).to include(p.headers.inspect) }
    end
  end

  describe "#autoupdate=" do
    it "sets the 'update' header to 'now' if truthy assigned value" do
      @temporary_post.autoupdate = true
      expect(@temporary_post.headers[:update]).to eq("now")
    end

    it "removes the 'update' header entirely if falsey assigned value" do
      @temporary_post.autoupdate = false
      expect(@temporary_post.headers.key?(:update)).to be_falsey
    end

    it "marks the post as autoupdate? == true" do
      expect(@temporary_post.autoupdate?).to be_falsey
      @temporary_post.autoupdate = true
      expect(@temporary_post.autoupdate?).to be_truthy
    end
  end

  describe "#autoupdate?" do
    it "returns true if there is an update: now header" do
      allow(@temporary_post).to receive(:headers) { { :update => "foo" } }
      expect(@temporary_post.autoupdate?).to be_falsey
      allow(@temporary_post).to receive(:headers) { { :update => "now" } }
      expect(@temporary_post.autoupdate?).to be_truthy
    end

    it "is ignorant of whitespace in the update header value" do
      allow(@temporary_post).to receive(:headers) { { :update => "now" } }
      expect(@temporary_post.autoupdate?).to be_truthy

      (1..3).each do |left|
        (1..3).each do |right|
          allow(@temporary_post).to receive(:headers) { { :update => "#{" " * left}now#{" " * right}"} }
          expect(@temporary_post.autoupdate?).to be_truthy
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
        expect(@temporary_post.updated).not_to eq(old_update_time)
        expect(@temporary_post.updated.to_i).to eq(t.to_i)
        expect(@temporary_post.headers[:updated].to_i).to eq(t.to_i)
      end
    end

    it "calls save and writes out the new timestamp value, without a publish: now header" do
      expect(@temporary_post).to receive(:save).once.and_call_original

      t = Time.now + 50
      Timecop.freeze(t) do
        @temporary_post.update!

        file_content = Redhead::String[File.read(@temporary_post.path)]
        expect(Time.parse(file_content.headers[:updated].value).to_i).to eq(t.to_i)
        expect(file_content.headers[:publish]).to be_nil
      end
    end

    it "marks the post as no longer auto-updating" do
      expect(@temporary_post.autoupdate?).to be_falsey
      @temporary_post.autoupdate = true
      expect(@temporary_post.autoupdate?).to be_truthy
      @temporary_post.update!
      expect(@temporary_post.autoupdate?).to be_falsey
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
        expect(liq.key?(e)).to be_truthy
      end
    end
  end
end
