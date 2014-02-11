require "spec_helper"

describe Serif::Config do
  subject do
    Serif::Config.new(testing_dir("_config.yml"))
  end

  describe "#admin_username" do
    it "is the admin username defined in the config file" do
      subject.admin_username.should == "test-changethisusername"
    end
  end

  describe "#admin_password" do
    it "is the admin password defined in the config file" do
      subject.admin_password.should == "test-changethispassword"
    end
  end

  describe "#image_upload_path" do
    it "defaults to /images/:timestamp/_name" do
      subject.stub(:yaml) { {} }
      subject.image_upload_path.should == "/images/:timestamp_:name"
    end
  end

  describe "#permalink" do
    it "is the permalink format defined in the config file" do
      subject.permalink.should == "/test-blog/:title"
    end

    it "defaults to /:title" do
      subject.stub(:yaml) { {} }
      subject.permalink.should == "/:title"
    end
  end

  describe "#archive_url_format" do
    it "defaults to /archive/:year/:month" do
      subject.stub(:yaml) { {} }
      subject.archive_url_format.should == "/archive/:year/:month"
    end

    it "is the archive_url_format found in the config file" do
      subject.archive_url_format.should == "/test-archive/:year/:month"
    end
  end

  describe "#archive_enabled?" do
    it "defaults to false" do
      subject.stub(:yaml) { {} }
      subject.archive_enabled?.should be_false
    end
  end
end