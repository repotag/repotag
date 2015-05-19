require 'spec_helper'

describe "admin/email/smtp/show.html.erb" do
  
  before(:each) do
    @smtp_settings = Setting.get(:smtp_settings)
    render
  end
  
  it "shows a table with smtp settings" do
    expect(rendered).to have_text('Server')
    expect(rendered).to have_text @smtp_settings[:smtp_address]
  end
end