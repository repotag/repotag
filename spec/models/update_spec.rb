require 'spec_helper'

describe "Update" do
  
  before(:each) do
    # @issue = FactoryGirl.create(:issue)
  end
  
  it "should be of a specific type (subclass)"
  
  it "should belong to an Issue"
  
  it "should belong to a User"
  
  it "should have a serialized hash for storing information" 
  
  describe "Update::Comment" do
    before(:each) do
      # @comment = FactoryGirl.create(:comment)
    end
    
    it "should have text" do
      skip
      expect(@comment.data).to_not be_nil
    end
    
  end
  
  describe "Update::StatusEvent" do
    before(:each) do
      # @status_event = FactoryGirl.create(:status_event)
    end
    
    it "should have very specific strings signaling the type of event" do
      skip
      ['open', 'close', 'lock', 'unlock'].each do |status|
        @status_event.data = status
        expect(@status_event.save).to be_truthy
      end
      @status_event.data = 'random string'
      expect(@status_event.save).to be_falsy
    end
    
  end
  
  describe "Update::LabelEvent" do
    before(:each) do
      # @label_event = FactoryGirl.create(:label_event)
    end
    
    it "should have a label_id to look up the corresponding label" do
      skip
      expect(@label_event.data.to_i).to be_a Fixnum
      label = Label.find(@label_event.data.to_i)
      expect(label).to_not be_nil
      expect(label).to be_a Label
    end
    
    it "should only allow numbers" do
      skip
      @label_event.data = 'random string'
      expect(@label_event.save).to be_falsy
    end
    
  end
  
end