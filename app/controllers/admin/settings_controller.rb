class Admin::SettingsController < Admin::AdminController
  load_and_authorize_resource
  
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