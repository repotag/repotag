require 'spec_helper'

describe "repositories/new" do
  before(:each) do
    assign(:repository, stub_model(Repository).as_new_record)
  end

  it "renders new repository form" do
   skip
   render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", repositories_path, "post" do
    end
  end
end
