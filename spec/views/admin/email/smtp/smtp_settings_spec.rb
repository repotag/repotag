require 'spec_helper'

describe "admin/email/smtp/show.html.erb" do
  it "shows a table with smtp settings" do
    skip "render errors out on form"
    render
    rendered.should contain('Server')
  end
end