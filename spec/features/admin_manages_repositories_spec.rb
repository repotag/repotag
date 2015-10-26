require 'spec_helper'

def create_repository(name)
  visit "/repositories"
  click_link 'New Repository'
  fill_in "Name", with: name
  click_button 'Save Repository'
end

feature "Admin manages repositories" do
  let(:user) { FactoryGirl.create(:user) }

  before do
    user.set_admin(true)
    http_auth(user.username, user.password)
  end
  
  scenario "by viewing all repositories" do
    repo = FactoryGirl.create(:repository)
    visit "/admin/repositories"
    expect(page).to have_text "#{repo.name}"
  end
  
  scenario "by creating a repository" do
    create_repository("Turtles")
    expect(page).to have_text "Repository was successfully created."
  end

  scenario "by archiving a repository with wiki" do
    skip
    repo = FactoryGirl.create(:repository_with_wiki)
    repo.to_disk
    visit "/admin/repositories"
    all(".fa-archive").last.click
    expect(page).to have_css('i.fa-refresh')
  end
  
  scenario "by archiving a repository without wiki" do
    skip
    repo = FactoryGirl.create(:repository)
    repo.to_disk
    visit "/admin/repositories"
    all(".fa-archive").last.click
    expect(page).to have_css('i.fa-refresh')
  end
  
  scenario "by unarchiving a repository with wiki" do
    skip
    repo = FactoryGirl.create(:repository_with_wiki)
    repo.to_disk
    visit "/admin/repositories"
    all(".fa-refresh").last.click
    expect(page).to have_css('i.fa-archive')
  end

  scenario "by unarchiving a repository without wiki" do
    skip
    repo = FactoryGirl.create(:repository)
    repo.to_disk
    visit "/admin/repositories"
    all(".fa-refresh").last.click
    expect(page).to have_css('i.fa-archive')
  end
  
  after do
    user.set_admin(false)
  end
end

feature "Admin manages repositories with js", :js => true do
  let(:user) { FactoryGirl.create(:user) }

  before do
    user.set_admin(true)
    http_auth(user.username, user.password)
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