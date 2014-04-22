module MarkdownPreviewsSteps
  include AdminNavigationMacros

  step "I press preview on a :post_or_draft that has content" do |post_type|
    step "I go to the new draft page"
    fill_in :markdown, with: "# Here is my heading\n\n```ruby\ndef foo(*)\n  :foo\nend\n```\n\nAll **done!**"
    find("label", text: "Preview").click
  end

  step "I should see the rendered preview" do
    expect(page).to have_selector("h1", text: "Here is my heading")
    expect(page).to have_selector("p", text: "All done!")
    expect(page).to have_selector("strong", text: "done!")
    expect(page).to have_selector("pre.highlight code", text: "def foo(*) :foo end")
  end
end
