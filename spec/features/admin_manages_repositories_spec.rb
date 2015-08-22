require 'spec_helper'

def login_helper
  Proc.new {
    @admin = FactoryGirl.create(:user)
    @admin.set_admin(true)
    
    @repos = []
    2.times { @repos << FactoryGirl.create(:repository) }
    
    http_auth(@admin.username, @admin.password)
  }
end

def create_repository(name)
  visit "/admin/repositories"
  click_link 'New Repository'
  fill_in "Name", with: name
  click_button 'Save Repository'
end

feature "Admin manages repositories" do
  before :each do
    login_helper.call
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
end

feature "Admin manages repositories with js", :js => true do
  before :each do
    login_helper.call
  end
  
  scenario "by deleting a repository" do
    name = "Turtles"
    create_repository(name)
    visit "/admin/repositories"
    page.accept_alert 'Are you sure?' do
      all(".fa-trash-o").last.click
    end
    expect(page).to have_text "Repository #{name} was successfully deleted."
  end
end