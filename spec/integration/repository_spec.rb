require 'spec_helper'

describe "repository" do
  
  before :each do
    @repo = FactoryGirl.create(:repository)
    @user = @repo.owner
    http_auth(@user.username,'koekje123')
    RJGit::Repo.any_instance.stub(:valid?) { true }
  end
  
  describe "list" do
    it 'displays a heading' do
      visit repositories_path
      page.should have_content('Listing repositories')
    end
  end

  describe "viewer" do
  
    it 'displays its name' do
      visit repository_path(@repo)
      page.should have_content("#{@repo.name}")
    end
  
    it 'displays its files' do
      visit repository_path(@repo)
      page.should have_xpath("//ol[@class='tree']/li") 
    end
  
    it 'displays its directories' do
      visit repository_path(@repo)
      page.should have_xpath("//ol[@class='tree']/li") 
    end
  
    it "displays its breadcrumb path" do
      visit repository_path(@repo)
      page.should have_content("/")
    end
    
  end

end