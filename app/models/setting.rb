class Setting < ActiveRecord::Base
  serialize :settings
  attr_accessible :settings, :name
  
  validates_presence_of :name
  
  SMTP_DEFAULTS = {:address => 'localhost', :port => 1025}
  
  def self.get(name)
    setting = Setting.where(:name => name).first_or_create!
    if setting.settings.nil?
      setting.settings = {} 
      setting.save
    end
    setting
  end
  
end
