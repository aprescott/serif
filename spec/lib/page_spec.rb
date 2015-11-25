RSpec.describe Serif::Page do
  let(:site) { double }
  let(:file_contents) { "header_a: val-1\nheader_b: val-2\n\nthese are file contents" }

  subject { Serif::Page.new(site, "some-file.html") }

  before do
    allow(File).to receive(:read).and_call_original
    allow(File).to receive(:read).with("some-file.html").and_return(file_contents)
  end

  its(:site) { should eq(site) }
  its(:path) { should eq("some-file.html") }

  describe "#render" do
    before do
      template = double
      allow(Liquid::Template).to receive(:parse).with("these are file contents").and_return(template)
      allow(template).to receive(:render!).with("site" => site, "page" => hash_including("header_a" => "val-1", "header_b" => "val-2")).and_return("rendered template contents")

      allow(site).to receive(:source_path).with("_layouts", "default.html").and_return("default layout")
      allow(File).to receive(:read).with("default layout").and_return("default layout file contents")
      default_layout = double
      allow(Liquid::Template).to receive(:parse).with("default layout file contents").and_return(default_layout)

      allow(default_layout).to receive(:render!).with(
        "site" => site,
        "page" => hash_including("header_a" => "val-1", "header_b" => "val-2"),
        "content" => "rendered template contents"
      ).and_return("final rendered layout")
    end

    it "is the fully rendered layout" do
      expect(subject.render).to eq("final rendered layout")
    end

    context "when the file has a header which specifies the layout is 'none'" do
      let(:file_contents) { "header_a: val-1\nheader_b: val-2\nlayout: none\n\nthese are file contents" }

      it "renders only the file" do
        expect(subject.render).to eq("rendered template contents")
      end
    end

    context "when the file specifies a different layout" do
      let(:file_contents) { "header_a: val-1\nheader_b: val-2\nlayout: something-else\n\nthese are file contents" }

      before do
        allow(site).to receive(:source_path).with("_layouts", "something-else.html").and_return("an alternative layout")
        allow(File).to receive(:read).with("an alternative layout").and_return("alternative layout contents")
        alternative_layout = double
        allow(Liquid::Template).to receive(:parse).with("alternative layout contents").and_return(alternative_layout)

        allow(alternative_layout).to receive(:render!).with(
          "site" => site,
          "page" => { "header_a" => "val-1", "header_b" => "val-2", "layout" => "something-else" },
          "content" => "rendered template contents"
        ).and_return("final rendered alternative layout")
      end

      its(:render) { should eq("final rendered alternative layout") }
    end
  end
end
