require "test_helper"

describe Serif::Site do
  subject do
    Serif::Site.new(testing_dir)
  end

  describe "#conflicts" do
    context "with no arguments" do
      it "is nil if there are no conflicts" do
        subject.conflicts.should be_nil
      end

      it "is a map of url => conflicts_array if there are conflicts" do
        d = Serif::Draft.new(subject)
        conflicting_post = subject.posts.first
        d.slug = conflicting_post.slug
        d.title = "Anything you like"
        d.save("# Some content")

        # need this to be true
        d.url.should == conflicting_post.url

        begin
          conflicts = subject.conflicts
          conflicts.should_not be_nil
          conflicts.class.should == Hash
          conflicts.size.should == 1
          conflicts.keys.should == [conflicting_post.url]
          conflicts[conflicting_post.url].size.should == 2
        ensure
          FileUtils.rm(d.path)
        end
      end
    end

    context "with an argument given" do
      it "is nil if there are no conflicts" do
        subject.conflicts(subject.drafts.sample).should be_nil
        subject.conflicts(subject.posts.sample).should be_nil

        d = Serif::Draft.new(subject)
        subject.conflicts(d).should be_nil
      end

      it "is an array of conflicting content if there are conflicts" do
        d = Serif::Draft.new(subject)
        conflicting_post = subject.posts.first
        d.slug = conflicting_post.slug
        d.title = "Anything you like"
        d.save("# Some content")

        # need this to be true
        d.url.should == conflicting_post.url

        begin
          conflicts = subject.conflicts(d)
          conflicts.should_not be_nil
          conflicts.class.should == Array
          conflicts.size.should == 2
          conflicts.each do |e|
            e.url.should == conflicting_post.url
          end
        ensure
          FileUtils.rm(d.path)
        end
      end
    end
  end
  
  describe "#source_directory" do
    it "should be sane" do
      subject.directory.should == File.join(File.dirname(__FILE__), "site_dir")
    end
  end

  describe "#posts" do
    it "is the number of posts in the site" do
      subject.posts.length.should == 5
    end
  end

  describe "#drafts" do
    it "is the number of drafts in the site" do
      subject.drafts.length.should == 2
    end
  end

  describe "#private_url" do
    it "returns nil for a draft without an existing file" do
      d = double("")
      d.stub(:slug) { "foo" }
      subject.private_url(d).should be_nil
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

  describe "#archives" do
    it "contains posts given in reverse chronological order" do
      archives = subject.archives
      archives[:posts].each_cons(2) do |a, b|
        (a.created >= b.created).should be_true
      end

      archives[:years].each do |year|
        year[:posts].each_cons(2) do |a, b|
          (a.created >= b.created).should be_true
        end
        
        year[:months].each do |month|
          month[:posts].each_cons(2) do |a, b|
            (a.created >= b.created).should be_true
          end
        end
      end
    end
  end

  describe "#to_liquid" do
    it "uses the value of #archives without modification" do
      subject.should_receive(:archives).once
      subject.to_liquid
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
