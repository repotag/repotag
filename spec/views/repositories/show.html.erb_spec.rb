require 'spec_helper'

describe "repositories/show.html.erb" do
  before(:each) do  
    @repo = FactoryGirl.build_stubbed(:repository)
    assign(:repository, @repo)
    assign(:current_path, '')
    file_list, dir_list = get_listing(@repo, "refs/heads/master", nil)
    assign(:file_list, file_list)
    assign(:directory_list, dir_list)
    assign(:general_settings, Setting.get(:general_settings))
  end
  
  it "should display the repository name" do
    render
    expect(rendered).to have_text @repo.owner.username
    expect(rendered).to have_text @repo.name
  end
  
  it "should display a breadcrumb trail" do
  end
  
  it "should display" do
  end
  
end
