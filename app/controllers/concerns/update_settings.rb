module UpdateSettings
  extend ActiveSupport::Concern
  include Params::SettingParams
  def save_settings(resource, valid_keys = [], setting_key = nil, &block)
    if setting_key
      return false unless valid_keys.include?(@updated_key)
      settings = Setting.get(setting_key)
    elsif resource
      return false unless resource.class.default_settings.keys.include?(@updated_key)
      settings = resource.settings
    else
      return false
    end
    if block_given?
      yield settings
    else
      settings[@updated_key] = @value
    end
    settings.save
    settings
  end
end