require 'spec_helper'

describe "repositories/index.html.erb" do
  
  before(:each) do
    @repo = FactoryGirl.create(:repository)
    assign(:repositories, [@repo])
  end

  it "should display a table of repositories that the user has access to" do
    user = @repo.owner
    http_auth(user.username, user.password)
    allow(controller).to(receive(:current_user).and_return(user))
    render :template => 'repositories/index.html.erb'
    expect(rendered).to have_selector(:xpath, "//table[@class='table table-striped table-hover']")
    expect(rendered).to have_text "#{@repo.name}"
  end
  
  it "should display public repositories if ..." do
    skip "Controller currently redirects to frontpage; perhaps list public repos there?"
  end

end