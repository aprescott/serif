require "test_helper"

describe Serif::Site do
  subject do
    Serif::Site.new(testing_dir)
  end
  
  describe "#source_directory" do
    it "should be sane" do
      subject.directory.should == File.join(File.dirname(__FILE__), "site_dir")
    end
  end

  describe "#posts" do
    it "is the number of posts in the site" do
      subject.posts.length.should == 1
    end
  end

  describe "#drafts" do
    it "is the number of drafts in the site" do
      subject.drafts.length.should == 2
    end
  end

  describe "#latest_update_time" do
    it "is the latest time that a post was updated" do
      subject.latest_update_time.should == Serif::Post.all(subject).max_by { |p| p.updated }.updated
    end
  end

  describe "#site_path" do
    it "should be relative, not absolute" do
      p = Pathname.new(subject.site_path("foo"))
      p.relative?.should be_true
      p.absolute?.should be_false
    end

    it "takes a string and prepends _site to that path" do
      %w[a b c d e f].each do |e|
        subject.site_path(e).should == "_site/#{e}"
      end
    end
  end

  describe "#config" do
    it "is a Serif::Config instance" do
      subject.config.class.should == Serif::Config
    end

    it "should have the permalink format available" do
      subject.config.permalink.should_not be_nil
    end
  end

  describe "#archive_url_for_date" do
    it "uses the archive URL format from the config to construct an archive URL string" do
      date = Date.parse("2012-01-02")
      subject.archive_url_for_date(date).should == "/test-archive/2012/01"
    end
  end

  describe "#bypass?" do
    it "is false if the filename has a .html extension" do
      subject.bypass?("foo.html").should be_false
    end

    it "is false if the filename has an .xml extension" do
      subject.bypass?("foo.xml").should be_false
    end

    it "is true if the filename is neither xml nor html by extension" do
      subject.bypass?("foo.css").should be_true
    end
  end

  describe "#tmp_path" do
    it "takes a string and prepends tmp/_site to that path" do
      %w[a b c d].each do |e|
        subject.tmp_path(e).should == "tmp/_site/#{e}"
      end
    end

    it "should be relative, not absolute" do
      p = Pathname.new(subject.tmp_path("foo"))
      p.absolute?.should be_false
      p.relative?.should be_true
    end
  end
end
