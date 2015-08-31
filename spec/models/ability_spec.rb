require 'cancan/matchers'
require 'spec_helper'

all_repo_abilities = [:read, :edit, :update, :manage, :destroy]

repo_abilities = {
	:watcher => [:read],
	:contributor => [:read, :edit, :update]
}

describe "User" do
  describe "abilities" do
    subject(:ability){ Ability.new(user) }

    context "when admin user" do
      let(:user)  { FactoryGirl.create(:user)} 
      let(:other) { FactoryGirl.create(:user) }
      let(:repo)  { FactoryGirl.create(:repository) }

      before do
        user.set_admin(true)
      end

      it "can manage all resources" do
        [other, repo].each {|resource| expect(ability).to be_able_to(:manage, resource)}
      end

      after do
        user.set_admin(false)
      end
    end

    context "on users" do
      let(:user) {FactoryGirl.create(:user)}
      let(:other) {FactoryGirl.create(:user)}

      it "can only read and edit itself" do
        expect(ability).to_not be_able_to(:read, other)
        expect(ability).to_not be_able_to(:edit, other)
        expect(ability).to be_able_to(:read, user)
        expect(ability).to be_able_to(:edit, user)        
      end
    end

    context "on repositories" do

      context "when not persisted" do
        let(:user) { User.new }
        it { expect(ability).to_not be_able_to(:create, Repository) }
      end

      context "when has no role" do

        let(:user){ FactoryGirl.create(:user) }

        it "can create repositories" do
          expect(ability).to be_able_to(:create, Repository)
        end

        it "can only read public repositories" do
      	  repo = FactoryGirl.build_stubbed(:repository)
      	  all_repo_abilities.each do |is_not_able|
      	    expect(ability).to_not be_able_to(is_not_able, repo)
      	  end
          repo.public = true
      	  expect(ability).to be_able_to(:read, repo)
        end
      end

      repo_abilities.each do |role, abilities|
  	    context "when is a #{role}" do

  	      let(:user){ FactoryGirl.create("#{role}_role".to_sym).user }
  	      let(:repo){ user.send("#{role}_repositories".to_sym).first }

  	      abilities.each do |is_able|
  	        it{ should be_able_to(is_able, repo) }
  	      end
  	      unless abilities.include?(:manage) # If the user can :manage then it can do everything
  	        (all_repo_abilities - abilities).each do |is_not_able|
  	      	  it{ should_not be_able_to(is_not_able, repo)}
  	        end
  	      end
  	    end
      end

      context "when is an owner" do
        let(:user) { FactoryGirl.create(:repository).owner }
        it { should be_able_to(:manage, user.owned_repositories.first) }
      end
      
    end

  end
end