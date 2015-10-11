class UsersController < ApplicationController
  load_and_authorize_resource
  before_filter :find_user
  skip_authorize_resource :only => [:settings, :update_settings]

  include Params::UserParams
  include Params::SettingParams

  def show
    @user_settings = @user.settings
  end

  def settings
    authorize! :read, @user
    @user_settings = @user.settings
  end
  
  def update_settings
    authorize! :update, @user
    @user_settings = @user.settings

    if User.default_settings.keys.include?(@updated_key)
      @user_settings[@updated_key] = @value
      @user_settings.save
    end
    render '/users/settings'
  end
  
  def update
    respond_to do |format|
      if @user.update_attributes(user_params)
        format.html { redirect_to @user, :notice => 'Profile was successfully updated.' }
      else
        flash_save_errors "user", @user.errors
        format.html { render :action => 'edit' }
      end
    end
  end

  private

  def find_user
    @user = params[:id] ? User.friendly.find(params[:id]) : current_user
    if @user.nil?
      flash[:error] = "User does not exist."
      redirect_to :root
    end
  end

end