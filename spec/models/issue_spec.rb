require 'spec_helper'

describe "Issue" do
  
  before(:each) do
    # @issue = FactoryGirl.create(:issue)
  end
  
  it "should belong to a repository" do
    skip
    expect(@issue.repository).to_not be_nil
  end
  
  it "should belong to a user" do
    skip
    expect(@issue.user).to_not be_nil
  end
  
  it "should have a title"
  
  it "should have a description"
  
  it "can have many Updates"
  
  it "should have participants" do
    skip
    expect(@issue.participants).to_not be_empty
    expect(@issue.participants).to include(@issue.owner)
  end
  
  it "can have an assignee" do
    skip
    @issue.assignee = FactoryGirl.create(:user)
    expect(@issue.assignee).to be_a User
  end
  
  it "can be open or closed" do
    skip
    expect(@issue.open?).to be_false
    @issue.close
    expect(@issue.open?).to be_true
  end
  
  it "can be locked or unlocked" do
    skip
    expect(@issue.locked?).to be_false
    @issue.lock
    expect(@issue.locked?).to be_true
  end
  
  it "can belong to a Milestone" do
    skip
    milestone = FactoryGirl.create(:milestone)
    @issue.milestone = milestone
    expect(@issue.milestone.id).to be == milestone.id
  end
  
  
end