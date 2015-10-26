require 'spec_helper'

class RepositoriesController < ApplicationController
end

describe "repositories/show.html.erb" do
  
  before(:each) do
    @repo = FactoryGirl.create(:repository)
    @repo.to_disk
    assign(:user, @repo.owner)
    assign(:repository, @repo)
    assign(:general_settings, Setting.get(:general_settings))
    assign(:current_path, '')
  end
  
  describe "with commit" do
    before(:each) do
      @repo.populate_with_test_data
      assign(:commit, @repo.repository.commits.first)
      dir_list, file_list = get_listing(@repo.repository, "refs/heads/master", nil)
      assign(:file_list, file_list)
      assign(:directory_list, dir_list)
    
      render
    end
  
    it "should display the repository name" do
      expect(rendered).to have_text @repo.owner.username
      expect(rendered).to have_text @repo.name
    end
  
    it "should display a breadcrumb trail" do
      expect(rendered).to have_selector(:xpath, "//ul[@class='breadcrumb']")
    end
  
    it "should display committed directories" do
      expect(rendered).to have_selector(:xpath, "//tr[@data-path='scriptdir']")
      expect(rendered).to have_text "scriptdir"
    end
  
    it "should display committed files" do
      expect(rendered).to have_selector(:xpath, "//td[@class='blob']")
      expect(rendered).to have_text "README.md"
    end
    
    it "should display the rendered README if it exists" do
      skip "Not implemented yet."
    end

  end
  
  describe "without commit" do
    
    before(:each) { render }
    
    it "should report that the repository is empty" do
      expect(rendered).to have_text "Empty repository."
    end
    
    it "should not display the table" do
      expect(rendered).not_to have_selector(:xpath, "//table[@id='viewer']")
    end
  end
  
  after(:each) do
    remove_temp_path(@repo.repository.path)
  end
  
end
