require 'spec_helper'

feature "Admin manages repositories" do
  
  before(:each) do
    # Create admin user to run the tests with
    @admin = FactoryGirl.create(:user)
    @admin.set_admin(true)
    
    @repos = []
    2.times { @repos << FactoryGirl.create(:repository) }
    
    http_auth(@admin.username,'koekje123')
  end
  
  scenario "by viewing all repositories" do
    visit "admin/repositories"
    @repos.each do |repo|
      expect(page).to have_text "#{repo.name}"
    end
  end
  
  scenario "by creating a repository" do
    create_repository("Turtles")
    expect(page).to have_text "Repository was successfully created."
  end
  
  # scenario "by deleting a repository", :js => true do
  #   skip "Javascript not working since upgrade to Rails 4.2."
  #   create_repository("Turtles")
  #   click_button "delete"
  #   page.accept_alert 'Are you sure?' do
  #       click_button('Yes')
  #   end
  #   expect(page).to have_text "Repository Turtles was successfully deleted."
  # end
  
  def create_repository(name)
    visit "admin/repositories"
    click_link 'New Repository'
    fill_in "Name", with: "Turtles"
    click_button 'Save Repository'
  end
  
end