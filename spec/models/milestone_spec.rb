require 'spec_helper'

describe "Milestone" do
  
  before(:each) do
    # @milestone = FactoryGirl.create(:milestone)
  end

  it "should belong to a repository" do
    skip
    expect(@milestone.repository).to_not be_nil
    expect(@milestone.repository).to be_a Repository
  end
  
  it "should have a title"
  
  it "should have a description"
  
  

end