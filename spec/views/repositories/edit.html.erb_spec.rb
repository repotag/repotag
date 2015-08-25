require 'spec_helper'

describe "repositories/edit" do
  before(:each) do
    @repository = FactoryGirl.create(:repository)
  end

  it "renders the edit repository form" do
    render :template => 'repositories/edit.html.erb'

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", user_repository_path(@repository.owner, @repository), "post" do
    end
  end
end
