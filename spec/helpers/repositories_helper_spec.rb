require 'spec_helper'

describe RepositoriesHelper do

  describe "#image_for_file" do
    
    it "returns a folder icon for directories" do
      expect(image_for_file('/tmp/path', true)).to eq "/assets/fileicons/folder.png"
    end
    
    it "returns a specific icon for known file types" do
      expect(image_for_file('arpeggio.mp3')).to eq "/assets/fileicons/mp3.png"
    end
    
    it "returns a general file icon for unknown file types" do
      expect(image_for_file('super.dup')).to eq "/assets/fileicons/file.png"
    end
    
  end

end
