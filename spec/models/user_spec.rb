require 'spec_helper'

shared_examples_for "a model that validates presence of" do |property|
  it "#{property}" do
    @user.attributes = valid_user_attributes.except(property)
    @user.should_not be_valid
    @user.send("#{property.to_s}=", valid_user_attributes[property])
    @user.should be_valid
  end
end

describe User do
  
  context "model" do
 
  before :each do
    @user = User.new
  end
  
 it_behaves_like "a model that validates presence of", :name
 it_behaves_like "a model that validates presence of", :username
 it_behaves_like "a model that validates presence of", :email
 it_behaves_like "a model that validates presence of", :password
 it_behaves_like "a model that validates presence of", :password do
   before(:each) { @user = User.new; @user.stub(:new_record?) {false}; @user.updating_password = true }
 end
 
 it "should enforce uniqueness of email addresses" do
   @user.email = 'rspec@repotag.org'
   @user_with_same_email = @user.dup
   @user_with_same_email.email = @user.email.upcase
   @user_with_same_email.save

   @user_with_same_email.should_not be_valid
 end
 
 it "should not validate presence of password if it is not updating its password" do
   @user.stub(:new_record?) {false}
   @user.updating_password = false
   @user.attributes = valid_user_attributes.except(:password)
   @user.should be_valid
 end
 
 it "should tell whether its password is being updated" do
   @user.should respond_to(:updating_password)
 end
 
 it "should tell us when the presence of password should be validated" do
   @user.should respond_to(:should_validate_password?)
   @user.should_validate_password?.should be_truthy
   @user.stub(:new_record?) {false}
   @user.should_validate_password?.should be_falsy
   @user.updating_password = true
   @user.should_validate_password?.should be_truthy
 end
 
 it "stores a password encryptedly" do
   @user.attributes = valid_user_attributes.except(:password)
   @user.encrypted_password.should eql("")
   @user.should_not be_valid
   @user.password = valid_user_attributes[:password]
   @user.should be_valid
   @user.encrypted_password.should_not eql("")
 end
 
 skip "it requires a password confirmation"
 
  end

  context "instance" do
    before :each do
      @user = FactoryGirl.create(:user)
    end
    it "gets and sets the global admin role" do
      @user.should respond_to(:set_admin, :admin?)
      @user.should_not be_admin
      @user.set_admin(true)
      @user.should be_admin
    end
  end

end
