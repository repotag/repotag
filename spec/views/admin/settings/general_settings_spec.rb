require 'spec_helper'

describe "admin/settings/general/show.html.erb" do
  
  before(:each) do
    @general_settings = Setting.get(:general_settings)
    render
  end
  
  it "shows a table with general settings" do
  	['Repository root', 'Allow anonymous access', 'Enable public profiles', 'Enable wikis globally', 'Enable issue tracker globally', 'Default branch'].each do |setting|
  		expect(rendered).to have_text(setting)
    end
  end
end