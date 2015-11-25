RSpec.describe "Archives" do
  before { generate_site }

  describe "Main archive page" do
    subject { Nokogiri::HTML.parse(File.read(testing_dir("_site/archive.html"))) }

    it "includes one year for each year with a published post" do
      expect(subject.search(".year-date").map(&:text)).to eq([
        "2400 (post count: 1)",
        "2399 (post count: 1)",
        "2015 (post count: 4)",
        "1921 (post count: 1)",
        "1920 (post count: 1)"
      ])
    end

    it "includes months within each year" do
      expect(subject.search(".year").map { |e| e.search(".month-date").map(&:text) }).to eq([
        ["2400 January (post count: 1)"],
        ["2399 January (post count: 1)"],
        ["2015 March (post count: 1)", "2015 January (post count: 3)"],
        ["1921 January (post count: 1)"],
        ["1920 January (post count: 1)"]
      ])
    end

    it "provides an archive link" do
      expect(subject.search(".archive-link").map { |e| e.attr("href") }).to eq([
        "/test-archive/2400/01",
        "/test-archive/2399/01",
        "/test-archive/2015/03",
        "/test-archive/2015/01",
        "/test-archive/1921/01",
        "/test-archive/1920/01"
      ])
    end
  end

  describe "individual archive month pages" do
    subject { Nokogiri::HTML.parse(File.read(testing_dir("_site/test-archive/2015/01.html"))) }

    it "includes the month and posts" do
      expect(subject.search("h1").map(&:text)).to eq(["Jan 2015 (3)"])

      expect(subject.search("ul li a").map { |e| [e.attr("href"), e.text] }).to eq([
        ["/test-blog/test--posts-get-post-page-flag-true", "Sample post"],
        ["/test-blog/test--published-posts-get-draft-preview-false", "No draft preview flag test"],
        ["/test-blog/test--permalinks-from-config-file", "A post"]
      ])
    end
  end
end
