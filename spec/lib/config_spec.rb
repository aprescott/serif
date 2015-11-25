RSpec.describe Serif::Config do
  let(:config_file) { double }
  let(:config_hash) { { "x" => 1 } }

  subject(:config) { Serif::Config.new(config_file) }

  before do
    allow(YAML).to receive(:load_file).with(config_file).and_return(config_hash)
  end

  describe "#permalink" do
    its(:permalink) { should eq("/:title") }

    context "with a specific value in the config file" do
      let(:config_hash) { { "x" => 1, "permalink" => "/some/format/:title" } }

      its(:permalink) { should eq("/some/format/:title") }
    end
  end

  describe "#archive_enabled?" do
    its(:archive_enabled?) { should be_falsey }

    context "when the config file specifies archived: enabled: true" do
      let(:config_hash) { { "x" => 1, "archive" => { "enabled" => true } } }

      its(:archive_enabled?) { should be_truthy }
    end

    context "when the config file specifies archived: enabled: false" do
      let(:config_hash) { { "x" => 1, "archive" => { "enabled" => false } } }

      its(:archive_enabled?) { should be_falsey }
    end

    context "when the config file specifies archived:, but not an enabled value" do
      let(:config_hash) { { "x" => 1, "archive" => {} } }

      its(:archive_enabled?) { should be_falsey }
    end
  end

  describe "#archive_url_format" do
    its(:archive_url_format) { should eq("/archive/:year/:month") }

    context "when the config file specifies archived: url_format:" do
      let(:config_hash) { { "x" => 1, "archive" => { "url_format" => "/some/format" } } }

      its(:archive_url_format) { should be_truthy }
    end

    context "when the config file specifies archived:, but not an url_format value" do
      let(:config_hash) { { "x" => 1, "archive" => {} } }

      its(:archive_url_format) { should eq("/archive/:year/:month") }
    end
  end
end
