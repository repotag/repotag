require 'spec_helper'

describe "repositories/index.html.erb" do
  
  before(:each) do
    # Create admin user to run the tests with
    @admin = FactoryGirl.build_stubbed(:user)
    @admin.set_admin(true)
    @repo = FactoryGirl.build_stubbed(:repository)
    assign(:repositories, [@repo])
  end

  it "should display a table of repositories that the user has access to" do
    user = @repo.owner
    http_auth(@admin.username,'koekje123')
    allow(controller).to(receive(:current_user).and_return(user))
    render
    expect(rendered).to have_selector(:xpath, "//table[@class='table table-striped table-hover']")
    expect(rendered).to have_text "#{@repo.name}"
  end
  
  it "should display public repositories if ..." do
    skip "Controller currently redirects to frontpage; perhaps list public repos there?"
  end

end