class Admin::SettingsController < Admin::AdminController
  load_and_authorize_resource
  
  def show_smtp_settings
    @setting = Setting.get(:smtp_settings)
    @smtp_settings = @setting.settings
    Rails.logger.debug @smtp_settings
    
    respond_to do |format|
      format.html { render 'admin/email/smtp/show'}
      format.json { render :json => @smtp_settings }
    end
    
  end
  
  def update_smtp_settings
    updated_settings = params[:setting][:smtp_settings].symbolize_keys.slice(:address, :port, :domain, :user_name, :password, :authentication, :enable_starttls_auto)
    Repotag::Application.config.action_mailer.smtp_settings.merge!(updated_settings)
    smtp_settings = Setting.get(:smtp_settings)
    smtp_settings.settings.merge!(updated_settings)
    smtp_settings.save
    flash[:notice] = "SMTP settings have been saved successfully."
    redirect_to '/admin/email/smtp'
  end
  
  def send_test_mail
    Mailer.test_email(current_user).deliver
    flash[:notice] = "A test mail has been sent to the server."
    redirect_to '/admin/email/smtp' 
  end
  
end