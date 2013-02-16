require "test_helper"

describe Serif::Post do
  subject do
    Serif::Site.new(testing_dir)
  end

  before :all do
    @posts = subject.posts
  end

  it "uses the config file's permalink value" do
    @posts.all? { |p| p.url == "/test-blog/#{p.slug}" }.should be_true
  end

  describe "#inspect" do
    it "includes headers" do
      @posts.all? { |p| p.inspect.should include(p.headers.inspect) }
    end
  end
end