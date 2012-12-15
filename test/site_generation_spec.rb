require "test_helper"

describe Serif::Site do
  subject do
    Serif::Site.new(testing_dir)
  end

  before(:each) do
    FileUtils.rm_rf(testing_dir("_site"))
  end

  it "uses the permalinks in the config file for site generation" do
    subject.generate
    File.exist?(testing_dir("_site/test-blog/sample-post.html")).should be_true
  end
end