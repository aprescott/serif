RSpec.describe "Creating a new site" do
  around do |example|
    begin
      create_new_site(testing_dir("../new_source"))

      example.run
    ensure
      FileUtils.rm_r(testing_dir("../new_source"))
    end
  end

  def directory_signatures(directory)
    Dir[File.join(directory, "/**/*")].select do |f|
      File.file?(f)
    end.map do |x|
      [x.sub(/\A#{directory}/, ""), Digest::SHA256.hexdigest(File.read(x))]
    end
  end

  it "should generate _site/ immediately" do
    expect(File.exist?(testing_dir("../new_source/_site"))).to be_truthy
  end

  it "should create a new site based on the fixed site template" do
    FileUtils.rm_r(testing_dir("../new_source/_site"))

    original_skeleton_tree = directory_signatures(testing_dir("../../site_template"))
    generated_tree = directory_signatures(testing_dir("../new_source"))

    expect(generated_tree).to eq(original_skeleton_tree)
  end

  it "includes a default _config.yml" do
    expect(YAML.load_file(testing_dir("../new_source/_config.yml"))).to eq(
      "permalink" => "/:title",
      "archive" => {
        "enabled" => true,
        "url_format" => "/archive/:year/:month"
      }
    )
  end
end
