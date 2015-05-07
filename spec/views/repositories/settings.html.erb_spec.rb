require 'spec_helper'

describe 'repositories/settings.html.erb' do
  before(:each) do
    @repo = FactoryGirl.build_stubbed(:repository)
    assign(:repository, @repo)
  end
  
  it "should list settings that are specific to a repository" do
    render
    expect(rendered).to have_text "Settings specific to Repository #{@repo.name}"
  end
  
end