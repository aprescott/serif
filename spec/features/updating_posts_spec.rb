RSpec.describe "Post updating" do
  describe "the 'update: now' header" do
    it "sets the Updated header value to the current time" do
      with_file_contents(testing_dir("_posts/2000-12-20-test--published-post"), "title: Some post title\nCreated: 2000-12-20T14:15:16Z\nupdate: now\n\nchanges made") do
        expect(File.read(testing_dir("_posts/2000-12-20-test--published-post")).split("\n\n").first).to_not match(/\nUpdated: #{Time.now.strftime("%Y")}-/)
        expect(File.read(testing_dir("_posts/2000-12-20-test--published-post")).split("\n\n").first).to end_with("\nupdate: now")

        generate_site

        expect(File.read(testing_dir("_posts/2000-12-20-test--published-post")).split("\n\n").first).to match(/\nCreated: 2000-12-20T14:15:16Z\nUpdated: #{Time.now.strftime("%Y-%m-%dT")}\d\d:\d\d:\d\d#{Regexp.quote Time.now.xmlschema.split(/\d\d:\d\d:\d\d/).last}\z/)
        expect(File.read(testing_dir("_posts/2000-12-20-test--published-post")).split("\n\n").first).to_not include("update: now")
      end
    end

    it "overrides an existing Updated header value by taking precedence" do
      with_file_contents(testing_dir("_posts/2000-12-20-test--published-post"), "title: Some post title\nCreated: 2000-12-20T14:15:16Z\nUpdated: 2001-01-01T14:15:16Z\nupdate: now\n\nchanges made") do
        expect(File.read(testing_dir("_posts/2000-12-20-test--published-post")).split("\n\n").first).to_not match(/\nUpdated: #{Time.now.strftime("%Y")}-/)
        expect(File.read(testing_dir("_posts/2000-12-20-test--published-post")).split("\n\n").first).to end_with("\nupdate: now")

        generate_site

        expect(File.read(testing_dir("_posts/2000-12-20-test--published-post")).split("\n\n").first).to match(/\nCreated: 2000-12-20T14:15:16Z\nUpdated: #{Time.now.strftime("%Y-%m-%dT")}\d\d:\d\d:\d\d#{Regexp.quote Time.now.xmlschema.split(/\d\d:\d\d:\d\d/).last}\z/)
        expect(File.read(testing_dir("_posts/2000-12-20-test--published-post")).split("\n\n").first).to_not include("update: now")
      end
    end
  end
end
