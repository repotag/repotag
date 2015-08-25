require 'spec_helper'

describe "repositories/new" do
  before(:each) do
    repo = FactoryGirl.create(:repository)
    assign(:repository, repo)
  end

  it "renders new repository form" do
    skip
    render :template => 'repositories/new.html.erb'
  end
end
