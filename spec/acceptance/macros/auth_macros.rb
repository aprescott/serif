module AuthMacros
  step "I am logged in as an admin user" do
    basic_auth "test-changethisusername", "test-changethispassword"
    visit "/admin"

    expect(page).to have_content("Admin")
  end

  private

  def basic_auth(user, password)
    encoded_login = ["#{user}:#{password}"].pack("m*")
    page.driver.header "Authorization", "Basic #{encoded_login}"
  end
end

RSpec.configure do |config|
  config.include AuthMacros, type: :feature
end
