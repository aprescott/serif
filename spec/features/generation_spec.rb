RSpec.describe "Site generation with serif generate" do
  before :all do
    generate_site
  end

  it "uses the the permalink value in the config file by default" do
    expect(File.exist?(testing_dir("_site/test-blog/test--permalinks-from-config-file.html"))).to be_truthy
  end

  it "uses a custom layout: header value for a non-post file, if specified" do
    expect(File.read(testing_dir("_site/test--page-with-a-custom-layout-header-value.html"))).to match(/<h1.+?>Alternate layout<\/h1>/)
  end

  it "uses a custom layout: header value for a post file, if specified" do
    expect(File.read(testing_dir("_site/test-blog/test--post-with-custom-layout.html"))).to match(/<h1.+?>Alternate layout<\/h1>/)
  end

  it "generates links for the next and previous posts" do
    first_post_content = File.read(testing_dir("_site/test-blog/test--page-links--very-first-post.html"))
    second_post_content = File.read(testing_dir("_site/test-blog/test--page-links--second-post.html"))
    penultimate_post_content = File.read(testing_dir("_site/test-blog/test--page-links--penultimate-post.html"))
    final_post_content = File.read(testing_dir("_site/test-blog/test--page-links--final-post.html"))

    expect(first_post_content).to_not include("Previous post")
    expect(first_post_content).to include("Next post: Second post")

    expect(second_post_content).to include("Previous post: Very first post")
    expect(second_post_content).to include("Next post:")

    expect(penultimate_post_content).to include("Previous post:")
    expect(penultimate_post_content).to include("Next post: Final post")

    expect(final_post_content).to include("Previous post: Penultimate post")
    expect(final_post_content).to_not include("Next post")
  end

  it "sets the draft_preview flag to true for drafts" do
    draft_preview_path = Dir[testing_dir("_site/drafts/test--drafts-get-draft-preview-true/*.html")].first
    preview_contents = File.read(draft_preview_path)
    published_contents = File.read(testing_dir("_site/test-blog/test--published-posts-get-draft-preview-false.html"))

    draft_preview_flag_content = "this is a draft preview"
    expect(preview_contents).to include(draft_preview_flag_content)
    expect(published_contents).to_not include(draft_preview_flag_content)
  end

  it "ses the post_page flag to true for published posts" do
    draft_preview_path = Dir[testing_dir("_site/drafts/test--drafts-get-post-page-flag-false/*.html")].first
    preview_contents = File.read(draft_preview_path)
    published_contents = File.read(testing_dir("_site/test-blog/test--posts-get-post-page-flag-true.html"))
    page_contents = File.read(testing_dir("_site/test--page-get-post-page-flag-false.html"))

    expect(published_contents).to include("post_page flag set for template")
    expect(published_contents).to include("post_page flag set for layout")

    expect(preview_contents).to_not include("post_page flag set for template")
    expect(preview_contents).to_not include("post_page flag set for layout")

    expect(page_contents).to_not include("post_page flag set for template")
    expect(page_contents).to_not include("post_page flag set for layout")
  end

  it "generates preview files for drafts" do
    draft_directory = testing_dir("_site/drafts/test--drafts-get-a-preview")

    # it's a directory
    expect(Dir.exist?(draft_directory)).to be_truthy
    expect(File.file?(draft_directory)).to be_falsey

    draft_preview_path = Dir[File.join(draft_directory, "*.html")].first

    # its actual name is all hex characters
    expect(draft_preview_path).to_not be_nil
    expect(File.basename(draft_preview_path)).to match(/\A[a-f0-9]{60}.html\z/)

    # each draft gets its own file
    expect(Dir[testing_dir("_site/drafts/*")].length).to eq(3)

    # hex filenames are consistent: they're re-used if they already exist
    generate_site
    expect(Dir[File.join(draft_directory, "*.html")].length).to eq(1)
    expect(File.basename(Dir[File.join(draft_directory, "*.html")].first)).to eq(File.basename(draft_preview_path))
  end
end
