RSpec.describe "Draft post" do
  it "remains unpublished without changes" do
    generate_site
    expect(Dir[testing_dir("_site/test-blog/*")].length).to eq(8)
    expect(Dir[testing_dir("_drafts/*")].length).to eq(3)

    with_file_contents(testing_dir("_drafts/test--new-draft"), "title: new draft\n\nsome content") do
      expect(Dir[testing_dir("_drafts/*")].length).to eq(4)
      expect { generate_site }.to_not change { Dir[testing_dir("_site/test-blog/*")].length }
      expect(Dir[testing_dir("_drafts/*")].length).to eq(4)
    end
  end

  describe "the 'publish: now' header" do
    it "will auto-publish on generation" do
      generate_site

      with_file_contents(testing_dir("_drafts/test--new-draft"), "title: new draft\npublish: now\n\nsome content", removal_path: testing_dir("_posts/#{Time.now.strftime("%Y-%m-%d")}-test--new-draft")) do
        expect(Dir[testing_dir("_drafts/*")].length).to eq(4)
        expect { generate_site }.to change { Dir[testing_dir("_site/test-blog/*")].length }.from(8).to(9)
        expect(Dir[testing_dir("_drafts/*")].length).to eq(3)

        newly_published_content = File.read(testing_dir("_posts/#{Time.now.strftime("%Y-%m-%d")}-test--new-draft"))
        timestamp = /#{Time.now.strftime("%Y-%m-%dT")}\d\d:\d\d:\d\d#{Regexp.quote Time.now.xmlschema.split(/\d\d:\d\d:\d\d/).last}/

        expect(newly_published_content).to match(/\Atitle: new draft\nCreated: #{timestamp.source}\nUpdated: #{timestamp.source}\n\nsome content\n\z/)
      end
    end
  end
end
