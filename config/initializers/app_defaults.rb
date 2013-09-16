GENERAL_DEFAULTS = {:repo_root => '/tmp/repos', :anonymous_access => false}

def set_general_defaults
  s = Setting.where(:name => :general_settings).first
  if s.nil?
    Setting.create(:name => :general_settings, :settings => GENERAL_DEFAULTS )
  end
end

SMTP_DEFAULTS = {:address => 'localhost', :port => 1025}
  
def set_smtp_defaults
  s = Setting.where(:name => :smtp_settings).first
  if s.nil?
    Setting.create(:name => :smtp_settings, :settings => SMTP_DEFAULTS )
  end
end

AUTH_PROVIDERS = [:google_oath2, :facebook, :github]

def set_authentication_defaults
  s = Setting.where(:name => :authentication_settings).first
  if s.nil?
    default_settings = {}
    AUTH_PROVIDERS.each do |provider|
      default_settings[provider] = {:app_id => nil, :app_secret => nil}
    end
    Setting.create(:name => :authentication_settings, :settings => default_settings)
  end
end

set_general_defaults
set_smtp_defaults
set_authentication_defaults