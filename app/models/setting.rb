class Setting < ActiveRecord::Base
  serialize :settings
  validates_presence_of :name

  def self.get(name)
    setting = Setting.where(:name => name).first_or_create!
    if setting.settings.nil?
      setting.settings = {}
      setting.save
    end
    setting
  end

  alias_method :a_r_reader, :[]
  def [](key)
    return settings[key] if settings[key]
    self.send(:a_r_reader, key)
  end

  alias_method :a_r_writer, :[]=
  def []=(key, value)
    unless self.send(:a_r_reader, key).nil?
      self.send(:a_r_writer, key, value)
    else
      settings[key] = value
    end
  end

end
