class UsersController < ApplicationController
  load_and_authorize_resource
  skip_authorize_resource :only => [:show, :settings, :update_settings]
  skip_load_resource :only => [:settings, :update_settings]

  def show
    @user_settings = @user.settings
  end

  def settings
    @user = params[:user] ? User.friendly.find(params[:user]) : current_user
    authorize! :read, @user
    @user_settings = @user.settings
  end
  
  def update_settings
    @user = params[:user] ? User.friendly.find(params[:user]) : current_user
    authorize! :update, @user
    updated_key = params[:name].to_sym
    @user_settings = @user.settings

    if User.default_settings.keys.include?(updated_key)
      @user_settings[updated_key] = params[:value]
      @user_settings.save
    end
    render '/users/settings'
  end
  
  def update
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, :notice => 'Profile was successfully updated.' }
      else
        flash_save_errors "user", @user.errors
        format.html { render :action => 'edit' }
      end
    end
  end
end