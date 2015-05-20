require 'spec_helper'

describe "Label" do
  
  before(:each) do
    # @label = FactoryGirl.create(:label)
  end

  it "should belong to a repository" do
    skip
    expect(@label.repository).to_not be_nil
  end
  
  it "should belong to an issue" do
    skip
    expect(@label.issue).to_not be_nil
    expect(@label.issue).to be_a Issue
  end
  
  it "should have a text" do
    skip
    expect(@label.text).to be == "Feature"
  end
  
  it "should have a color" do
    skip
    expect(@label.color).to be == "red"
  end
  
end