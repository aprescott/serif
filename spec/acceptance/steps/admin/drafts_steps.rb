module DraftsSteps
  step "I go to the new draft page" do
    click_on "New draft"
  end

  step "I type up a new post" do
    fill_in :slug, with: "new-awesome-post"
    fill_in :title, with: "New Post"
    fill_in :markdown, with: "My new post content."

    click_on "Save draft"
  end

  step "I should see the newly saved draft" do
    expect(page).to have_content("new-awesome-post")
    # TODO: ugh
    FileUtils.rm_f testing_dir("_drafts/new-awesome-post")
  end
end