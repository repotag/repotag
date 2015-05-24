require 'spec_helper'

describe 'repositories/settings.html.erb' do
  before(:each) do
    @repo = FactoryGirl.create(:repository)
    assign(:repository, @repo)
    assign(:repository_settings, @repo.settings)
    assign(:contributors, @repo.contributing_users)
  end
  
  it "should list settings that are specific to a repository" do
    render
    expect(rendered).to have_text "Settings specific to Repository #{@repo.name}"
  end
  
  describe "without contributors" do
    before(:each) { render }
    
    it "should note that there are no contributors" do
      expect(rendered).to have_text "There are no contributors"
    end
  end
  
  describe "with contributors" do
    before(:each) do
      @contributor = FactoryGirl.create(:user)
      @contributor.add_role(:contributor, @repo)
      assign(:contributors, @repo.contributing_users)
      render
    end
    
    it "should list contributors" do
      expect(rendered).to have_text @contributor.username
      expect(rendered).to have_text @contributor.name
    end
  end
  
end