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
end