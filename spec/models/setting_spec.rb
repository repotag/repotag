require 'spec_helper'

describe Setting do
  
  describe "SMTP settings" do
    before(:each) do
      @smtp_settings = Setting.get(:smtp_settings)
      smtp_defaults = {:address => 'localhost', :port => 1025}
      @smtp_settings.settings = smtp_defaults
      @smtp_settings.save
    end
    
    it "should have an address and a port" do
      @smtp_settings[:address].should_not be_nil
      @smtp_settings[:port].should_not be_nil
    end
    
  end
  
  describe "Generic Setting record" do
    before(:each) do
      @rspec_test_settings = Setting.get(:rspec_test)
    end
    it "should have a settings field that is a hash" do
      @rspec_test_settings.settings.should be_a Hash
      @rspec_test_settings.settings.should be_empty
    end
  
    it "should serialize an arbitrary hash" do
      @rspec_test_settings.settings = {:rspec => true}
      @rspec_test_settings[:test_framework] = 'rspec'
      @rspec_test_settings.save
      @rspec_test_settings.settings[:rspec].should be_true
      @rspec_test_settings.settings[:test_framework].should == 'rspec'
    end

    after(:each) do
      @rspec_test_settings.destroy
    end
  end  
end
