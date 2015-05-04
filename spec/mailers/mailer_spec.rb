require "spec_helper"

describe Mailer do
  msg = Message.new
  mailer = Mailer.new_message(msg)
  
  before(:each) do
    @user = FactoryGirl.create(:user)
  end
  
  it "sends a test email for checking smtp server settings" do
    expect(mailer.to[0]).to eq 'repotag@repotag.org'
    Mailer.test_email(@user).deliver_now
    expect(ActionMailer::Base.deliveries).to have(1).email
  end
end
