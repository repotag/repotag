require 'spec_helper'

shared_examples_for "a model that validates presence of" do |property|
  it "#{property}" do
    @user.attributes = valid_user_attributes.except(property)
    @user.should_not be_valid
    @user[property] = valid_user_attributes[property]
    @user.should be_valid
  end
end

describe User do
  
  pending "Each user's e-mail address should be unique"
  
  before :each do
    @user = User.new
  end
  
 it_behaves_like "a model that validates presence of", :name
 it_behaves_like "a model that validates presence of", :username
 it_behaves_like "a model that validates presence of", :email
 
 it "is no admin by default" do
   @user.should_not be_admin
 end
 
 it "does not let admin be set by mass assignment" do
     expect do
       @user.update_attributes(:admin => true)
     end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
 end
 
 it "gets and sets admin status" do
   @user.should respond_to(:admin, :admin?)
   @user.should_not be_admin
   @user.admin = true
   @user.should be_admin
 end
 
 it "stores a password encryptedly" do
   @user.attributes = valid_user_attributes.except(:password)
   @user.encrypted_password.should eql("")
   @user.should_not be_valid
   @user.password = valid_user_attributes[:password]
   @user.should be_valid
   @user.encrypted_password.should_not eql("")
 end
 
 pending "it requires a password confirmation"

end
