class Admin::SettingsController < Admin::AdminController
  load_and_authorize_resource

  # General Settings

  def show_general_settings
    @general_settings = Setting.get(:general_settings)

    respond_to do |format|
      format.html { render 'admin/settings/general/show'}
      format.json { render :json => @general_settings }
    end

  end

  def update_general_settings
    Rails.logger.debug params
    updated_key = params[:name].to_sym
    Rails.logger.debug updated_key

    valid_keys = [:repo_root, :anonymous_access, :public_profiles]
    if valid_keys.include?(updated_key)

      @general_settings = Setting.get(:general_settings)
      @general_settings[updated_key] = params[:value]
      @general_settings.save
      render '/admin/settings/general/show'
    end
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
    updated_key = params[:name].to_sym

    valid_keys = [:google_oauth2_app_id, :google_oauth2_app_secret, :google_oauth2_enabled, :facebook_app_id, :facebook_app_secret, :facebook_enabled, :github_app_id, :github_app_secret, :github_enabled]
    if valid_keys.include?(updated_key)
      provider = updated_key.to_s.split('_').first
      provider = (provider == 'google' ? 'google_oauth2' : provider) 
      @authentication_settings = Setting.get(:authentication_settings)
      @authentication_settings[provider.to_sym][updated_key] = params[:value]
      @authentication_settings.save
      Rails.logger.debug @authentication_settings.errors.inspect
      render '/admin/settings/authentication/show'
    end
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
    Rails.logger.debug params
    updated_key = params[:name].to_sym
    Rails.logger.debug updated_key

    valid_keys = [:address, :port, :domain, :user_name, :password, :authentication, :enable_starttls_auto]
    if valid_keys.include?(updated_key)

      @smtp_settings = Setting.get(:smtp_settings)
      @smtp_settings[updated_key] = params[:value]
      @smtp_settings.save
      if Repotag::Application.config.action_mailer.smtp_settings.nil?
        Repotag::Application.config.action_mailer.smtp_settings = @smtp_settings.settings
      else
        Repotag::Application.config.action_mailer.smtp_settings.merge!(@smtp_settings.settings)
      end
      render '/admin/email/smtp/show'
    end
  end

  def send_test_mail
    Mailer.test_email(current_user).deliver
    flash[:notice] = "A test mail has been sent to the server."
    redirect_to '/admin/email/smtp'
  end

end