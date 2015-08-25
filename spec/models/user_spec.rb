require 'spec_helper'
require 'ostruct'

describe User do

  context 'validations' do
    it_behaves_like "a model that has settings", :user, [:notifications_as_watcher, :notifications_as_collaborator]

    [:name, :username, :email].each do |attribute|
      it { should validate_presence_of(attribute) }
    end

    subject(:user) { FactoryGirl.create(:user) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_uniqueness_of(:username).case_insensitive }

    it 'validates presence of password when necessary' do
      allow(user).to receive(:should_validate_password?).and_return(true)
      expect(user).to validate_presence_of(:password)
      allow(user).to receive(:should_validate_password?).and_return(false)
      expect(user).to_not validate_presence_of(:password)
      allow(user).to receive(:should_validate_password?).and_call_original
    end

    it 'indicates whether the presence of password should be validated' do
      allow(user).to receive(:new_record?).and_return(true)
      expect(user.should_validate_password?).to be_truthy
      allow(user).to receive(:new_record?).and_return(false)
      expect(user.should_validate_password?).to be_falsy
      user.updating_password = true
      expect(user.should_validate_password?).to be_truthy
      allow(user).to receive(:new_record?).and_call_original
    end

    it 'stores a password encryptedly' do
      user.password = nil
      user.encrypted_password = nil
      user.password = valid_attributes_for_model(User)[:password]
      expect(user.encrypted_password).to_not be_empty
    end

    skip 'it requires a password confirmation'

  end

  context 'instance' do
    before :each do
      @user = FactoryGirl.create(:user)
      @repo = FactoryGirl.create(:repository)
    end

    it 'sets whether it is public' do
      expect(@user).to be_public
      @user.toggle(:public)
      expect(@user).to_not be_public
    end
    
    it 'gets, sets and loses the global admin role' do
      expect(@user).to respond_to(:set_admin, :admin?)
      expect(@user).to_not be_admin
      @user.set_admin(true)
      expect(@user).to be_admin
      @user.set_admin(false)
      expect(@user).to_not be_admin
    end

    it 'lists its owned repositories' do
      expect(@repo.owner.owned_repositories).to include(@repo)
    end

    [:watcher, :contributor].each do |role|
      it "lists repositories on which it's a #{role}" do
        repo = FactoryGirl.create(:repository)
        expect(@user.send("#{role}_repositories".to_sym)).to_not include(repo)
        @user.add_role(role, repo)
        expect(@user.send("#{role}_repositories".to_sym)).to include(repo)
      end
    end

    it 'lists all its repositories' do
      expect(@repo.owner.all_repositories).to include(@repo)
      repo2 = FactoryGirl.create(:repository)
      @repo.owner.add_role(:watcher, repo2)
      expect(@repo.owner.all_repositories).to include(repo2)
    end

    it 'gets its role on a resource' do
      repo = FactoryGirl.create(:repository)
      expect(@user.has_role?(:watcher, repo)).to be false
      @user.add_role(:watcher, repo)
      expect(@user.has_role?(:watcher, repo)).to be true
    end
    
    it 'lists its role for a resource' do
      repo = FactoryGirl.build_stubbed(:repository)
      owner = repo.owner
      expect(@user.role_for(repo)).to be_nil
      @user.add_role(:watcher, repo)
      expect(owner.role_for(repo)).to be_nil
      expect(owner.role_for(repo, true)).to be == :owner
      expect(@user.role_for(repo)).to be == :watcher
    end
  end

  context 'class' do

    before do
      @user = FactoryGirl.create(:user)
    end

    it 'finds users for third-party authentication' do
      access_token = OpenStruct.new(:info => {'email' => @user.email, 'name' => @user.name})
      faux_access_token = OpenStruct.new(:info => {})
      ['facebook', 'google_oauth2']. each do |service|
        expect(User.send("find_for_#{service}".to_sym, access_token)).to eq @user
        expect(User.send("find_for_#{service}".to_sym, faux_access_token)).to be_a User
      end
    end

    it 'finds users for device authentication' do
      expect(User.find_first_by_auth_conditions({:username => @user.username})).to eq @user
      expect(User.find_first_by_auth_conditions({:username => 'nonexistent'})).to be_nil
      expect(User.find_first_by_auth_conditions({:login => @user.username})).to eq @user
      expect(User.find_first_by_auth_conditions({:login => @user.email})).to eq @user
    end

  end

end
