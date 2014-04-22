module DraftsSteps
  include AdminNavigationMacros

  step "I type up a new post" do
    type_out_draft
  end

  step "I save the draft" do
    click_on "Save draft"
  end

  step "I've saved a draft" do
    step "I go to the new draft page"
    step "I type up a new post"
    step "I save the draft"
  end

  step "I should be able to see its contents" do
    click_on "new-awesome-post"
    expect(page).to have_content("My new post content.")
    # TODO: ugh
    FileUtils.rm_f testing_dir("_drafts/new-awesome-post")
  end

  step "I should see the newly saved draft" do
    expect(page).to have_content("new-awesome-post")
    # TODO: ugh
    FileUtils.rm_f testing_dir("_drafts/new-awesome-post")
  end

  step "I type up a post with the slug missing" do
    type_out_draft(:title, :markdown)
  end

  step "I type up a post with the title missing" do
    type_out_draft(:slug, :markdown)
  end

  step "I should see an error message" do
    expect(page).to have_content("There must be a URL, a title, and content to save.")
  end

  step "the draft body should still be there" do
    expect(page).to have_field(:markdown, with: "My new post content.")
  end

  step "I create a new draft" do
    step "I go to the new draft page"
    step "I type up a new post"
    step "I save the draft"
  end

  step "I view the draft for editing" do
    click_on "new-awesome-post"
  end

  step "I save the post with new content but no slug" do
    fill_in :markdown, with: "Changed content."
    fill_in :slug, with: ""
    click_on "Update draft"
  end

  step "my new content should be there" do
    expect(page).to have_field(:markdown, with: "Changed content.")
  end

  step "I should see an error about being unable to update" do
    expect(page).to have_content("You must pick a URL to use")
    # TODO: ugh
    FileUtils.rm_f testing_dir("_drafts/new-awesome-post")
  end

  private

  def type_out_draft(*fields)
    fields = [:slug, :title, :markdown] if fields && fields.empty?
    fields = [] if !fields

    fill_in :slug, with: "new-awesome-post" if fields.include?(:slug)
    fill_in :title, with: "New Post" if fields.include?(:title)
    fill_in :markdown, with: "My new post content." if fields.include?(:markdown)
  end
end
