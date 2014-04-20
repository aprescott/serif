require "spec_helper"

describe Serif::Config do
  subject do
    Serif::Config.new(testing_dir("_config.yml"))
  end

  describe "#admin_username" do
    it "is the admin username defined in the config file" do
      expect(subject.admin_username).to eq("test-changethisusername")
    end
  end

  describe "#admin_password" do
    it "is the admin password defined in the config file" do
      expect(subject.admin_password).to eq("test-changethispassword")
    end
  end

  describe "#image_upload_path" do
    it "defaults to /images/:timestamp/_name" do
      allow(subject).to receive(:yaml) { {} }
      expect(subject.image_upload_path).to eq("/images/:timestamp_:name")
    end
  end

  describe "#permalink" do
    it "is the permalink format defined in the config file" do
      expect(subject.permalink).to eq("/test-blog/:title")
    end

    it "defaults to /:title" do
      allow(subject).to receive(:yaml) { {} }
      expect(subject.permalink).to eq("/:title")
    end
  end

  describe "#archive_url_format" do
    it "defaults to /archive/:year/:month" do
      allow(subject).to receive(:yaml) { {} }
      expect(subject.archive_url_format).to eq("/archive/:year/:month")
    end

    it "is the archive_url_format found in the config file" do
      expect(subject.archive_url_format).to eq("/test-archive/:year/:month")
    end
  end

  describe "#archive_enabled?" do
    it "defaults to false" do
      allow(subject).to receive(:yaml) { {} }
      expect(subject.archive_enabled?).to be_false
    end
  end
end
