RSpec.describe "Directory creation during site generation" do
  before do
    FileUtils.rm_rf(testing_dir("_site"))
  end

  describe "_site" do
    it "is created if it doesn't exist" do
      expect { generate_site }.to change { File.exist?(testing_dir("_site")) }.from(false).to(true)
    end
  end

  describe "_site/drafts" do
    it "is created if it doesn't exist" do
      expect { generate_site }.to change { File.exist?(testing_dir("_site/drafts")) }.from(false).to(true)
    end

    it "is not created if there are no drafts" do
      begin
        FileUtils.mv(testing_dir("_drafts"), testing_dir("_drafts.temp"))

        expect { generate_site }.to_not change { File.exist?(testing_dir("_site/drafts")) }.from(false)
      ensure
        FileUtils.mv(testing_dir("_drafts.temp"), testing_dir("_drafts"))
      end
    end
  end
end
