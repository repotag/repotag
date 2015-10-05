require 'spec_helper'

feature "Admin manages users" do

  let(:user) { FactoryGirl.create(:user) }
  
  before do
    user.set_admin(true)
    http_auth(user.username,user.password)
  end
  
  feature "by creating a user" do

    scenario "with valid fields" do
      create_user("Tester Bob", "bob@repotag.org")
      expect(page).to have_text "User was successfully created"
    end
  
    scenario "with invalid email" do
      create_user("Tester Bob", "fake_email")
      expect(page).to have_text "errors prevented this user from being saved"
      expect(page).to have_text "Email is invalid"
    end
  
  end
  
  feature "by updating a user" do
    scenario "with valid fields" do
      create_user("Tester Bob", "bob@repotag.org")
      update_user_email("bob@repotag.org", "bobbyt@repotag.org")
      expect(page).to have_text "User was successfully updated"
    end

    scenario "by setting global admin role" do
      email = "bob@repotag.org"
      create_user("Tester Bob", email)
      user = User.where(email: email).first
      expect(user).to_not be_admin
      set_admin_checkbox(user, true)
      expect(user).to be_admin
      set_admin_checkbox(user, false)
      expect(user).to be_admin
    end
    
    scenario "with invalid fields" do
      create_user("Tester Bob", "bob@repotag.org")
      update_user_email("bob@repotag.org", "")
      expect(page).to have_text "Email can't be blank"
    end
  end

  def set_admin_checkbox(user, value)
    visit edit_admin_user_path(user)
    box = find(:checkbox, "admin")
    expect(box.checked?).to eq (value == true ? nil : "checked" )
    box.set(value)
    click_button 'Save'
  end
  
  def create_user(name, email)
    visit "admin/users"
    click_link "Add new user"
    fill_in "Email", with: email
    fill_in "Name", with: name
    fill_in "Username", with: name.squeeze.gsub(/\s/, '').downcase.strip
    fill_in "Password", with: "BobbyT123"
    fill_in "Password Confirmation", with: "BobbyT123"
    click_button 'Save'
  end
  
  def update_user_email(email, new_email)
    user = User.where(email: email).first
    visit edit_admin_user_path(user)
    fill_in "Email", with: new_email
    click_button 'Save'
  end
  
end