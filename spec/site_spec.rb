RSpec.describe Serif::Site do
  subject do
    Serif::Site.new(testing_dir)
  end

  describe "#conflicts" do
    context "with no arguments" do
      it "is nil if there are no conflicts" do
        expect(subject.conflicts).to be_nil
      end

      it "is a map of url => conflicts_array if there are conflicts" do
        d = Serif::Draft.new(subject)
        conflicting_post = subject.posts.first
        d.slug = conflicting_post.slug
        d.title = "Anything you like"
        d.save("# Some content")

        # need this to be true
        expect(d.url).to eq(conflicting_post.url)

        begin
          conflicts = subject.conflicts
          expect(conflicts).not_to be_nil
          expect(conflicts.class).to eq(Hash)
          expect(conflicts.size).to eq(1)
          expect(conflicts.keys).to eq([conflicting_post.url])
          expect(conflicts[conflicting_post.url].size).to eq(2)
        ensure
          FileUtils.rm(d.path)
        end
      end
    end

    context "with an argument given" do
      it "is nil if there are no conflicts" do
        expect(subject.conflicts(subject.drafts.sample)).to be_nil
        expect(subject.conflicts(subject.posts.sample)).to be_nil

        d = Serif::Draft.new(subject)
        expect(subject.conflicts(d)).to be_nil
      end

      it "is an array of conflicting content if there are conflicts" do
        d = Serif::Draft.new(subject)
        conflicting_post = subject.posts.first
        d.slug = conflicting_post.slug
        d.title = "Anything you like"
        d.save("# Some content")

        # need this to be true
        expect(d.url).to eq(conflicting_post.url)

        begin
          conflicts = subject.conflicts(d)
          expect(conflicts).not_to be_nil
          expect(conflicts.class).to eq(Array)
          expect(conflicts.size).to eq(2)
          conflicts.each do |e|
            expect(e.url).to eq(conflicting_post.url)
          end
        ensure
          FileUtils.rm(d.path)
        end
      end
    end
  end

  describe "#source_directory" do
    it "should be sane" do
      expect(subject.directory).to eq(File.join(File.dirname(__FILE__), "site_dir"))
    end
  end

  describe "#posts" do
    it "is the number of posts in the site" do
      expect(subject.posts.length).to eq(5)
    end
  end

  describe "#drafts" do
    it "is the number of drafts in the site" do
      expect(subject.drafts.length).to eq(2)
    end
  end

  describe "#private_url" do
    it "returns nil for a draft without an existing file" do
      d = double("")
      allow(d).to receive(:slug) { "foo" }
      expect(subject.private_url(d)).to be_nil
    end
  end

  describe "#latest_update_time" do
    it "is the latest time that a post was updated" do
      expect(subject.latest_update_time).to eq(Serif::Post.all(subject).max_by { |p| p.updated }.updated)
    end
  end

  describe "#site_path" do
    it "should be relative, not absolute" do
      p = Pathname.new(subject.site_path("foo"))
      expect(p.relative?).to be_truthy
      expect(p.absolute?).to be_falsey
    end

    it "takes a string and prepends _site to that path" do
      %w[a b c d e f].each do |e|
        expect(subject.site_path(e)).to eq("_site/#{e}")
      end
    end
  end

  describe "#config" do
    it "is a Serif::Config instance" do
      expect(subject.config.class).to eq(Serif::Config)
    end

    it "should have the permalink format available" do
      expect(subject.config.permalink).not_to be_nil
    end
  end

  describe "#archives" do
    it "contains posts given in reverse chronological order" do
      archives = subject.archives
      archives[:posts].each_cons(2) do |a, b|
        expect(a.created >= b.created).to be_truthy
      end

      archives[:years].each do |year|
        year[:posts].each_cons(2) do |a, b|
          expect(a.created >= b.created).to be_truthy
        end

        year[:months].each do |month|
          month[:posts].each_cons(2) do |a, b|
            expect(a.created >= b.created).to be_truthy
          end
        end
      end
    end
  end

  describe "#to_liquid" do
    it "uses the value of #archives without modification" do
      expect(subject).to receive(:archives).once
      subject.to_liquid
    end
  end

  describe "#archive_url_for_date" do
    it "uses the archive URL format from the config to construct an archive URL string" do
      date = Date.parse("2012-01-02")
      expect(subject.archive_url_for_date(date)).to eq("/test-archive/2012/01")
    end
  end

  describe "#bypass?" do
    it "is false if the filename has a .html extension" do
      expect(subject.bypass?("foo.html")).to be_falsey
    end

    it "is false if the filename has an .xml extension" do
      expect(subject.bypass?("foo.xml")).to be_falsey
    end

    it "is true if the filename is neither xml nor html by extension" do
      expect(subject.bypass?("foo.css")).to be_truthy
    end
  end

  describe "#tmp_path" do
    it "takes a string and prepends tmp/_site to that path" do
      %w[a b c d].each do |e|
        expect(subject.tmp_path(e)).to eq("tmp/_site/#{e}")
      end
    end

    it "should be relative, not absolute" do
      p = Pathname.new(subject.tmp_path("foo"))
      expect(p.absolute?).to be_falsey
      expect(p.relative?).to be_truthy
    end
  end
end
