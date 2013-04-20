require "spec_helper"

describe Mailer do
  msg = Message.new
  mailer = Mailer.new_message(msg)
  mailer.to[0].should == 'patrick.pepels@gmail.com'
end
