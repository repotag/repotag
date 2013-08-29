class Setting < ActiveRecord::Base
  serialize :smtp_settings
  attr_accessible :smtp_settings
  
  SMTP_DEFAULTS = {:address => 'localhost', :port => 1025}
  
  def self.get
    @setting ||= Setting.where(:id => 1).first_or_create!
    if @setting.smtp_settings.nil?
      @setting.smtp_settings = SMTP_DEFAULTS 
      @setting.save
    end
    @setting
  end
  
end
