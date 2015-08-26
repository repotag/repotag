require 'spec_helper'

feature "User manages own profile" do
  before(:each) do
    @user = FactoryGirl.create(:user)
    http_auth(@user.username, @user.password)
    visit user_path(@user)
    click_link 'Edit'
  end
  
  scenario "by changing one's username" do
    fill_in "Name", with: "BobbyT"
    click_button "Update profile"
    expect(page).to have_text "Profile was successfully updated"
  end
  
  scenario "by changing one's email address" do
    fill_in "Email", with: "bobbyt@repotag.org"
    click_button "Update profile"
    expect(page).to have_text "Profile was successfully updated"
  end
  
  scenario "by changing one's avatar" do
    skip "change avatar logic not implemented yet"
  end
  
  scenario "and receives error notification on validation errors" do
    fill_in "Email", with: ""
    click_button "Update profile"
    expect(page).to have_text "Email can't be blank"
  end
  
end
