class Admin::SettingsController < Admin::AdminController
  include UpdateSettings

  def show_general_settings
    @general_settings = Setting.get(:general_settings)

    respond_to do |format|
      format.html { render 'admin/settings/general/show'}
      format.json { render :json => @general_settings }
    end

  end

  def update_general_settings
    valid_keys = [:repo_root, :archive_root, :wiki_root, :server_domain, :server_port, :ssl_enabled, :anonymous_access, :public_profiles, :enable_wikis, :enable_issuetracker, :default_branch]
    @general_settings = save_settings(nil, valid_keys, :general_settings)
    render '/admin/settings/general/show'
  end

  # Authentication Settings
  def show_authentication_settings
    @authentication_settings = Setting.get(:authentication_settings)

    respond_to do |format|
      format.html { render 'admin/settings/authentication/show'}
      format.json { render :json => @authentication_settings }
    end
  end
  
  def update_authentication_settings
    valid_keys = [:google_oauth2_app_id, :google_oauth2_app_secret, :google_oauth2_enabled, :facebook_app_id, :facebook_app_secret, :facebook_enabled, :github_app_id, :github_app_secret, :github_enabled]
    provider = @updated_key.to_s.split('_').first
    provider = (provider == 'google' ? 'google_oauth2' : provider)
    @authentication_settings = save_settings(nil, valid_keys, :authentication_settings) do |settings|
      settings[provider.to_sym][@updated_key] = @value
    end
    Rails.logger.debug @authentication_settings.errors.inspect
    render '/admin/settings/authentication/show'
  end

  # SMTP Settings
  def show_smtp_settings
    @smtp_settings = Setting.get(:smtp_settings)

    respond_to do |format|
      format.html { render 'admin/email/smtp/show'}
      format.json { render :json => @smtp_settings }
    end

  end

  def update_smtp_settings
    valid_keys = [:address, :port, :domain, :user_name, :password, :authentication, :enable_starttls_auto]
    @smtp_settings = save_settings(nil, valid_keys, :smtp_settings)
    if Repotag::Application.config.action_mailer.smtp_settings.nil?
      Repotag::Application.config.action_mailer.smtp_settings = @smtp_settings.settings
    else
      Repotag::Application.config.action_mailer.smtp_settings.merge!(@smtp_settings.settings)
    end
    render '/admin/email/smtp/show'
  end

  def send_test_mail
    Mailer.test_email(current_user).deliver_now
    flash[:notice] = "A test mail has been sent to the server."
    redirect_to '/admin/email/smtp'
  end

end