require 'spec_helper'

shared_examples_for "a model that validates presence of" do |property|
  it "#{property}" do
    @user.attributes = valid_user_attributes.except(property)
    expect(@user).to_not be_valid
    @user.send("#{property.to_s}=", valid_user_attributes[property])
    expect(@user).to be_valid
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
   before(:each) { @user = User.new; allow(@user).to receive(:new_record?).and_return(false); @user.updating_password = true }
 end
 
 it "enforces uniqueness of email addresses" do
   @user.email = 'rspec@repotag.org'
   @user_with_same_email = @user.dup
   @user_with_same_email.email = @user.email.upcase
   @user_with_same_email.save

   expect(@user_with_same_email).to_not be_valid
 end
 
 it "does not validate presence of password if it is not updating its password" do
   allow(@user).to receive(:new_record?).and_return(false)
   @user.updating_password = false
   @user.attributes = valid_user_attributes.except(:password)
   expect(@user).to be_valid
 end
 
 it "tells whether its password is being updated" do
   expect(@user).to respond_to(:updating_password)
 end
 
 it "tells us when the presence of password should be validated" do
   expect(@user).to respond_to(:should_validate_password?)
   expect(@user.should_validate_password?).to be_truthy
   allow(@user).to receive(:new_record?).and_return(false)
   expect(@user.should_validate_password?).to be_falsy
   @user.updating_password = true
   expect(@user.should_validate_password?).to be_truthy
 end
 
 it "stores a password encryptedly" do
   @user.attributes = valid_user_attributes.except(:password)
   expect(@user.encrypted_password).to be_empty
   expect(@user).to_not be_valid
   @user.password = valid_user_attributes[:password]
   expect(@user).to be_valid
   expect(@user.encrypted_password).to_not be_empty
 end
 
 skip "it requires a password confirmation"
 
 end

  context "instance" do
    before :each do
      @user = FactoryGirl.create(:user)
    end
    it "gets, sets and loses the global admin role" do
      expect(@user).to respond_to(:set_admin, :admin?)
      expect(@user).to_not be_admin
      @user.set_admin(true)
      expect(@user).to be_admin
      @user.set_admin(false)
      expect(@user).to_not be_admin
    end
  end

end
