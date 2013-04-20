require 'spec_helper'

describe "repository list" do
  it 'tells us it rules' do
    visit repositories_index_path
    page.should have_content('Heersch!')
  end
end

describe "repository viewer" do
    
  repo = Repository.create!(:name => "Test Repo")
  
  it 'displays its name' do
    visit repository_path(repo)
    page.should have_content("Repository Name: #{repo.name}")
  end
  
  it 'displays its files' do
    visit repository_path(repo)
    page.should have_content("Files:")
    page.should have_xpath("//ul[@id='files']/li") unless page.has_content?("Files: none.")
  end
  
  it 'displays its directories' do
    visit repository_path(repo)
    page.should have_content("Directories:")
    page.should have_xpath("//ul[@id='dirs']/li") unless page.has_content?("Directories: none.")
  end
  
  it "displays its breadcrumb path" do
    visit repository_path(repo)
    page.should have_content("Current Path: /")
  end
    
end