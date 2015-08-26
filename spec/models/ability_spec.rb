require 'cancan/matchers'
require 'spec_helper'

all_abilities = [:read, :edit, :manage, :destroy]

role_abilities = {
	:watcher => [:read],
	:contributor => [:read, :edit],
	:admin => [:manage],
}

describe "User" do
  describe "abilities" do
    subject(:ability){ Ability.new(user) }

    context "on repositories" do

      context "when has no role" do

        let(:user){ FactoryGirl.create(:user) }

        it "can only read public repositories" do
      	  repo = FactoryGirl.build_stubbed(:repository)
      	  repo2 = FactoryGirl.build_stubbed(:repository)
      	  repo2.public = true
      	  all_abilities.each do |is_not_able|
      	    expect(ability).to_not be_able_to(is_not_able, repo)
      	    expect(ability).to_not be_able_to(is_not_able, repo2) unless is_not_able == :read
      	  end
      	  expect(ability).to be_able_to(:read, repo2)
        end
      end

      role_abilities.each do |role, abilities|
  	    context "when is a #{role}" do

  	      let(:user){ FactoryGirl.create("#{role}_role".to_sym).user }
  	      let(:repo){ 
            user.respond_to?("#{role}_repositories".to_sym) ?
              user.send("#{role}_repositories".to_sym).first : FactoryGirl.build_stubbed(:repository)
          }

  	      abilities.each do |is_able|
  	        it{ should be_able_to(is_able, repo) }
  	      end
  	      unless abilities.include?(:manage) # If the user can :manage then it can do everything
  	        (all_abilities - abilities).each do |is_not_able|
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