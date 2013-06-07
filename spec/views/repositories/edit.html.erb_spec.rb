require 'spec_helper'

describe "repositories/edit" do
  before(:each) do
    @repository = assign(:repository, stub_model(Repository))
  end

  it "renders the edit repository form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", repository_path(@repository), "post" do
    end
  end
end
