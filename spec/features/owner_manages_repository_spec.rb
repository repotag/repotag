require 'spec_helper'

feature "Owner manages own repository" do
  before(:each) do
    @repo = FactoryGirl.create(:repository)
    @owner = @repo.owner
    http_auth(@owner.username,'koekje123')
    visit "#{@owner.username}/#{@repo.name}"
  end
  
  scenario "by changing settings" do
  end

end