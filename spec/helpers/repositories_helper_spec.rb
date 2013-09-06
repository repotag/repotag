require 'spec_helper'

describe RepositoriesHelper do

  describe "#image_for_file" do
    
    it "should return a folder icon for directories" do
      image_for_file('/tmp/path', true).should == "/assets/fileicons/folder.png"
    end
    
    it "should return a specific icon for known file types" do
      image_for_file('arpeggio.mp3').should == "/assets/fileicons/mp3.png"
    end
    
    it "should return a general file icon for unknown file types" do
      image_for_file('super.dup').should == "/assets/fileicons/file.png"
    end
    
  end

end
