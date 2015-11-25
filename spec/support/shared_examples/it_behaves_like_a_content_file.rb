RSpec.shared_examples "a content file" do
  before do
    allow(File).to receive(:read).and_call_original
    allow(File).to receive(:read).with(file_path).and_return(file_contents)
  end

  subject { described_class.new(site, file_path) }

  its(:site) { should eq(site) }
  its(:path) { should eq(file_path) }

  describe "#initialize" do
    it "errors if an argument is missing" do
      expect { described_class.new(nil, nil).to raise_error(ArgumentError, "must provide both site and path") }
      expect { described_class.new("value", nil).to raise_error(ArgumentError, "must provide both site and path") }
      expect { described_class.new(nil, "value").to raise_error(ArgumentError, "must provide both site and path") }
    end

    it "loads the contents of the file" do
      subject

      expect(File).to have_received(:read).with(file_path)
    end
  end

  describe "#draft?" do
    let(:is_published) { false }

    before do
      allow(subject).to receive(:published?).and_return(is_published)
    end

    its(:draft?) { should be_truthy }

    context "when the published? value is true" do
      let(:is_published) { true }

      its(:draft?) { should be_falsey }
    end
  end

  describe "#title" do
    let(:headers) { {} }

    before do
      allow(subject).to receive(:headers).and_return(headers)
    end

    its(:title) { should be_nil }

    context "when the headers have a title" do
      let(:headers) { { x: 1, title: "some title" } }

      its(:title) { should eq("some title") }
    end
  end

  describe "#content" do
    its(:content) { should eq("some content") }

    context "when the file has no content" do
      let(:file_contents) { "" }

      its(:content) { should eq("") }
    end

    context "when the file has only headers" do
      let(:file_contents) { "x: 1 "}

      its(:content) { should eq("") }

      context "and the headers are followed by the header separator" do
        its(:content) { should eq("") }
      end
    end
  end

  describe "#created" do
    let(:headers) { {} }

    before do
      allow(subject).to receive(:headers).and_return(headers)
    end

    its(:created) { should be_nil }

    context "when the headers have a Created value" do
      let(:time) { Time.parse("2015-01-01 20:00:00 +0500") }
      let(:headers) { { x: 1, created: time } }

      its(:created) { should eq(time) }

      it "is always in UTC" do
        expect(subject.created.zone).to eq("UTC")
      end
    end
  end

  describe "#updated" do
    let(:headers) { { x: 1 } }

    before do
      allow(subject).to receive(:headers).and_return(headers)
    end

    its(:updated) { should be_nil }

    context "when the headers have a Updated value" do
      let(:time) { Time.parse("2015-01-01 20:00:00 +0500") }
      let(:headers) { { x: 1, updated: time } }

      its(:updated) { should eq(time) }

      it "is always in UTC" do
        expect(subject.updated.zone).to eq("UTC")
      end
    end

    context "when there is no Updated header value but there is a Created value" do
      let(:created_time) { Time.parse("2015-01-01 20:00:00 +0500") }
      let(:headers) { { x: 1 } }

      before do
        allow(subject).to receive(:created).and_return(created_time)
      end

      its(:updated) { should eq(created_time) }
    end

    context "when both an Updated header value and a Created time are given" do
      let(:created_time) { Time.parse("2015-01-01 20:00:00 +0500") }
      let(:updated_time) { Time.parse("2200-01-01 20:00:00 +0500") }
      let(:headers) { { x: 1, updated: updated_time } }

      before do
        allow(subject).to receive(:created).and_return(created_time)
      end

      its(:updated) { should eq(updated_time) }
    end
  end

  describe "#headers" do
    its(:headers) { should eq(x: "1") }

    context "with a variety of headers" do
      let(:file_contents) { "x: 1\ntitle:    some title\nsomething else: 123\n  hello  :  there" }

      its(:headers) { should eq(x: "1", title: "some title", :something_else => "123", _hello: "there") }
    end

    context "when the header name is 'created'" do
      let(:file_contents) { "created: 2015-01-01 12:30:45 +0500" }

      its(:headers) { should eq(created: Time.parse("2015-01-01 12:30:45 +0500")) }
    end

    context "when the header name is 'updated'" do
      let(:file_contents) { "updated: 2015-01-01 12:30:45 +0500" }

      its(:headers) { should eq(updated: Time.parse("2015-01-01 12:30:45 +0500")) }
    end

    context "when the header's capitalization is not all-lowercase" do
      let(:file_contents) { "X: 1\nyYy: 2\nZZZZZ: 3" }

      its(:headers) { should eq(x: "1", yyy: "2", zzzzz: "3") }
    end
  end

  describe "#save" do
    before do
      Timecop.freeze
      allow(File).to receive(:open).and_call_original

      yielded_file = double
      allow(File).to receive(:open).with(file_path, "w").and_yield(yielded_file)
      allow(yielded_file).to receive(:puts) { |new_content| allow(File).to receive(:read).with(file_path).and_return(new_content) }
    end

    it "sets the header's Update: time to the current time" do
      expect { subject.save }.to change { subject.headers[:updated] }.from(nil).to(Time.at(Time.now.to_i))
    end
  end

  describe "#to_liquid" do
    let(:headers) { { x: 1, y: 2 } }

    before do
      allow(subject).to receive(:headers).and_return(headers)
      allow(subject).to receive(:content).and_return("content value")
      allow(subject).to receive(:slug).and_return("slug value")
      allow(subject).to receive(:url).and_return("url value")
      allow(subject).to receive(:draft?).and_return("draft? value")
      allow(subject).to receive(:published?).and_return("published? value")

      # only applies to posts, but doesn't hurt the test for drafts
      allow(subject).to receive(:created).and_return("created value")
      allow(subject).to receive(:updated).and_return("updated value")
    end

    its(:to_liquid) { should eq({ "x" => 1, "y" => 2 }.merge(expected_liquid_hash)) }

    context "when there is a header value which conflicts with one of the defined liquid keys" do
      let(:headers) {
        h = {
          "x" => "header's 1",
          "y" => "header's 2",
          "content" => "header's content value",
          "slug" => "header's slug value",
          "url" => "header's url value",
          "draft" => "header's draft? value",
          "published" => "header's published? value"
        }

        h["created"] = "header's created value" if expected_liquid_hash.key?("created")
        h["updated"] = "header's updated value" if expected_liquid_hash.key?("updated")

        h
      }

      its(:to_liquid) { should eq({ "x" => "header's 1", "y" => "header's 2" }.merge(expected_liquid_hash)) }
    end
  end
end
