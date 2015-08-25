require 'spec_helper'

describe 'repositories/settings.html.erb' do
  before(:each) do
    @repo = FactoryGirl.create(:repository)
    assign(:repository, @repo)
    assign(:repository_settings, @repo.settings)
    assign(:contributors, @repo.contributing_users)
    assign(:general_settings, Setting.get(:general_settings))
  end
  
  it "should list settings that are specific to a repository" do
    render :template => 'repositories/settings.html.erb'
    expect(rendered).to have_text "Settings specific to Repository #{@repo.name}"
  end
  
  describe "without contributors" do
    before(:each) { render :template => 'repositories/settings.html.erb' }
    
    it "should note that there are no contributors" do
      expect(rendered).to have_text "There are no contributors"
    end
  end
  
  describe "with contributors" do
    before(:each) do
      @contributor = FactoryGirl.create(:user)
      @contributor.add_role(:contributor, @repo)
      assign(:contributors, @repo.contributing_users)
      render :template => 'repositories/settings.html.erb'
    end
    
    it "should list contributors" do
      expect(rendered).to have_text @contributor.username
      expect(rendered).to have_text @contributor.name
    end
  end
  
end