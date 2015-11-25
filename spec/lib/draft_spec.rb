RSpec.describe Serif::Draft do
  let(:site) { double }
  let(:file_contents) { "x: 1\n\nsome content" }
  let(:file_path) { "some-path" }

  include_examples "a content file" do
    let(:expected_liquid_hash) do
      {
        "content" => "content value",
        "slug" => "slug value",
        "url" => "url value",
        "draft" => "draft? value",
        "published" => "published? value"
      }
    end
  end

  describe ".all" do
    let(:draft_1) { double }
    let(:draft_2) { double }

    before do
      allow(site).to receive(:source_path).with("_drafts", "*").and_return("foo")

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

      allow(Serif::Draft).to receive(:new).with(site, "expanded-path-2").and_return(draft_1)
      allow(Serif::Draft).to receive(:new).with(site, "expanded-path-4").and_return(draft_2)
    end

    specify { expect(Serif::Draft.all(site)).to eq([draft_1, draft_2]) }
  end

  describe "#slug" do
    let(:file_path) { "some/path/to/a/file-goes-here" }

    its(:slug) { should eq("file-goes-here") }
  end

  describe "#published?" do
    its(:published?) { should eq(false) }
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
      let(:headers) { { permalink: "/foo/:year/bar/:month/baz/:day/xyz/:title" } }

      before do
        Timecop.freeze(Time.parse("2003-04-11 13:14:10 UTC"))
      end

      its(:url) { should eq("/foo/2003/bar/04/baz/11/xyz/file-slug")}
    end
  end

  describe "#publish!" do
    let(:published_file_conflict) { false }
    let(:file_contents) { "x: 1\npublish: existing publish header value\n\nsome content"}

    before do
      Timecop.freeze(Time.parse("2004-05-05 13:14:15 UTC"))

      allow(site).to receive(:source_path) { |x| "site source path for #{x}" }
      allow(FileUtils).to receive(:mkdir_p).with("site source path for _posts")
      allow(subject).to receive(:slug).and_return("file-slug")
      allow(File).to receive(:exist?).with("site source path for _posts/2004-05-05-file-slug").and_return(published_file_conflict)

      # save stubbing, so we can verify that source headers are updated
      allow(subject).to receive(:save).and_call_original
      allow(File).to receive(:open).and_call_original

      yielded_file = double
      allow(File).to receive(:open).with(file_path, "w").and_yield(yielded_file)
      allow(yielded_file).to receive(:puts) { |new_content| allow(File).to receive(:read).with(file_path).and_return(new_content) }

      allow(FileUtils).to receive(:mv)
    end

    it "creates the site's _posts directory" do
      subject.publish!

      expect(FileUtils).to have_received(:mkdir_p).with("site source path for _posts")
    end

    it "updates the Created header" do
      expect { subject.publish! }.to change { subject.headers[:created] }.from(nil).to(Time.at(Time.now.to_i))
    end

    it "removes the Publish header" do
      expect { subject.publish! }.to change { subject.headers[:publish] }.from("existing publish header value").to(nil)
    end

    it "calls save" do
      subject.publish!

      expect(subject).to have_received(:save)
    end

    it "moves the file to _posts" do
      subject.publish!

      expect(FileUtils).to have_received(:mv).with("some-path", "site source path for _posts/2004-05-05-file-slug")
    end

    context "when there is a published file with the same path" do
      let(:published_file_conflict) { true }

      specify { expect { subject.publish! }.to raise_error(RuntimeError, "found a conflict when trying to publish 2004-05-05-file-slug: a file with that name exists already") }
    end

    describe "#autopublish?" do
      let(:headers) { {} }

      before do
        allow(subject).to receive(:headers).and_return(headers)
      end

      its(:autopublish?) { should be_falsey }

      context "when there is an Update header value" do
        let(:headers) { { publish: "some value" } }

        its(:autopublish?) { should be_falsey }
      end

      context "when there is an Update header value with a value of 'now'" do
        let(:headers) { { publish: "now" } }

        its(:autopublish?) { should be_truthy }
      end

      context "when there is an Update header value with a value of '  now   '" do
        let(:headers) { { publish: "   now     " } }

        its(:autopublish?) { should be_truthy }
      end
    end

    describe "#render" do
      pending
    end
  end
end
