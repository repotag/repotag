class Admin::SettingsController < Admin::AdminController
  load_and_authorize_resource
  # authorize_resource :class => false
  
  def show_smtp_settings
    @setting = Setting.get
    @smtp_settings = @setting.smtp_settings
    Rails.logger.debug @smtp_settings
    # @smtp_settings = Repotag::Application.config.action_mailer.smtp_settings
    
    respond_to do |format|
      format.html { render 'admin/email/smtp/show'}
      format.json { render :json => @smtp_settings }
    end
    
    
  end
  
  def update_smtp_settings
    Rails.logger.debug Repotag::Application.config.action_mailer.smtp_settings.inspect
    Rails.logger.debug params[:setting][:smtp_settings].slice(:address)
    updated_settings = params[:setting][:smtp_settings].slice(:address, :port, :domain, :user_name, :password, :authentication, :enable_starttls_auto)
    Repotag::Application.config.action_mailer.smtp_settings.merge!(updated_settings)
    Setting.get.smtp_settings.merge!(updated_settings)
    Setting.get.save
    Rails.logger.debug Repotag::Application.config.action_mailer.smtp_settings.inspect
    Rails.logger.debug Setting.get.smtp_settings.inspect
    flash[:notice] = "SMTP settings have been saved successfully."
    redirect_to '/admin/email/smtp/index'
  end
  
end