RSpec.describe Serif::Post do
  let(:site) { double }
  let(:file_contents) { "x: 1\n\nsome content" }
  let(:file_path) { "x-y-z-some-path" }

  include_examples "a content file" do
    let(:expected_liquid_hash) do
      {
        "content" => "content value",
        "slug" => "slug value",
        "url" => "url value",
        "draft" => "draft? value",
        "published" => "published? value",
        "created" => "created value",
        "updated" => "updated value"
      }
    end
  end

  describe ".all" do
    let(:draft_1) { double }
    let(:draft_2) { double }

    before do
      allow(site).to receive(:source_path).with("_posts", "*").and_return("foo")

      allow(File).to receive(:file?).with("path-1").and_return(false)
      allow(File).to receive(:file?).with("path-2").and_return(true)
      allow(File).to receive(:file?).with("path-3").and_return(false)
      allow(File).to receive(:file?).with("path-4").and_return(true)

      allow(Dir).to receive(:[]).with("foo").and_return([
        "path-1",
        "path-2",
        "path-3",
        "path-4"
      ])

      allow(File).to receive(:expand_path) { |x| "expanded-#{x}" }

      allow(Serif::Post).to receive(:new).with(site, "expanded-path-2").and_return(draft_1)
      allow(Serif::Post).to receive(:new).with(site, "expanded-path-4").and_return(draft_2)
    end

    specify { expect(Serif::Post.all(site)).to eq([draft_1, draft_2]) }
  end

  describe "#slug" do
    let(:file_path) { "some/path/to/a/x-y-z-some-file-content" }

    its(:slug) { should eq("some-file-content") }
  end

  describe "#published?" do
    its(:published?) { should eq(true) }
  end

  describe "#url" do
    let(:headers) { {} }

    before do
      allow(site).to receive_message_chain(:config, :permalink).and_return("default-permalink/:title")
      allow(subject).to receive(:headers).and_return(headers)
      allow(subject).to receive(:slug).and_return("file-slug")
    end

    its(:url) { should eq("default-permalink/file-slug") }

    context "when there is a specific permalink header value" do
      let(:headers) { { permalink: "/foo/bar/:title" } }

      its(:url) { should eq("/foo/bar/file-slug") }
    end

    context "with a permalink format that includes a year, month, and day" do
      let(:headers) { { permalink: "/foo/:year/bar/:month/baz/:day/somethingsomething/:title" } }

      before do
        Timecop.freeze(Time.parse("2003-04-11 13:14:10 UTC"))
      end

      its(:url) { should eq("/foo/x/bar/y/baz/z/somethingsomething/file-slug")}
    end
  end

  describe "#autoupdate?" do
    let(:headers) { {} }

    before do
      allow(subject).to receive(:headers).and_return(headers)
    end

    its(:autoupdate?) { should be_falsey }

    context "when there is an Update header value" do
      let(:headers) { { update: "some value" } }

      its(:autoupdate?) { should be_falsey }
    end

    context "when there is an Update header value with a value of 'now'" do
      let(:headers) { { update: "now" } }

      its(:autoupdate?) { should be_truthy }
    end

    context "when there is an Update header value with a value of '  now   '" do
      let(:headers) { { update: "   now     " } }

      its(:autoupdate?) { should be_truthy }
    end
  end

  describe "#update!" do
    let(:file_contents) { "update: existing update header\n\nsome post contents" }

    before do
      # save stubbing, so we can verify that source headers are updated
      allow(subject).to receive(:save).and_call_original
      allow(File).to receive(:open).and_call_original

      yielded_file = double
      allow(File).to receive(:open).with(file_path, "w").and_yield(yielded_file)
      allow(yielded_file).to receive(:puts) { |new_content| allow(File).to receive(:read).with(file_path).and_return(new_content) }
    end

    it "calls save" do
      subject.update!
      expect(subject).to have_received(:save)
    end

    it "deletes the existing Update header" do
      expect { subject.update! }.to change { subject.headers[:update] }.from("existing update header").to(nil)
    end
  end

  describe "#render" do
    pending
  end
end
