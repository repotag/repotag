class Admin::SettingsController < Admin::AdminController
  #load_and_authorize_resource
  authorize_resource :class => false
  
  def show_smtp_settings
    @smtp_settings = Repotag::Application.config.action_mailer.smtp_settings
    
    respond_to do |format|
      format.html { render 'admin/email/smtp/show'}
      format.json { render :json => @smtp_settings }
    end
    
    
  end
  
  def edit_smtp_settings
  end
  
end