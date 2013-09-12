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

set_general_defaults
set_smtp_defaults
