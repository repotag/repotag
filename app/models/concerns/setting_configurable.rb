module SettingConfigurable
  extend ActiveSupport::Concern

  def settings
    setting = Setting.where("#{self.class.name.downcase}_id".to_sym => self).first_or_create
    if setting.name.nil?
      setting.name = self.name
      setting.save
    end
    if setting.settings.nil?
      if self.class.respond_to?(:default_settings) then
      	defaults = self.class.default_settings
      else
      	Rails.logger.debug "Please implement #{self.class.name}.default_settings!"
      	defaults = {}
      end
      setting.settings = defaults
      setting.save
    end
    setting    
  end
end