require 'spec_helper'

describe Setting do
  
  describe "SMTP settings" do
    before(:each) do
      @smtp_settings = Setting.get(:smtp_settings)
      smtp_defaults = {:address => 'localhost', :port => 1025}
      @smtp_settings.settings = smtp_defaults
      @smtp_settings.save
    end
    
    it "has an address and a port" do
      expect(@smtp_settings[:address]).to_not be_nil
      expect(@smtp_settings[:port]).to_not be_nil
    end
    
  end
  
  describe "General settings" do
    before(:each) do
      @general_settings = Setting.get(:general_settings)
    end
  end
  
  describe "Generic Setting record" do
    before(:each) do
      @rspec_test_settings = Setting.get(:rspec_test)
    end
    it "has a settings field that is a hash" do
      expect(@rspec_test_settings.settings).to be_a_kind_of(Hash)
      expect(@rspec_test_settings.settings).to be_empty
    end
  
    it "serializes an arbitrary hash" do
      @rspec_test_settings.settings = {:rspec => true}
      @rspec_test_settings[:test_framework] = 'rspec'
      @rspec_test_settings.save
      expect(@rspec_test_settings.settings[:rspec]).to be_truthy
      expect(@rspec_test_settings.settings[:test_framework]).to eq 'rspec'
    end

    after(:each) do
      @rspec_test_settings.destroy
    end
  end  
end
