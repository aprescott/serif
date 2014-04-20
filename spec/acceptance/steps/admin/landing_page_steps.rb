module LandingPageSteps
  step "I view the admin landing page" do
    visit "/admin"
  end

  step "I should see relevant summary information" do
    expect(page).to have_title("Admin")
    expect(page).to have_content("Drafts")
    expect(page).to have_content("Posts")
  end
end
