require "spec_helper"

describe Mailer do
  msg = Message.new
  mailer = Mailer.new_message(msg)
  mailer.to[0].should == 'repotag@repotag.org'
  
  before(:each) do
    @user = FactoryGirl.create(:user)
  end
  
  it "should send a test email for checking smtp server settings" do
    Mailer.test_email(@user).deliver
    ActionMailer::Base.deliveries.should have(1).email
  end
end
