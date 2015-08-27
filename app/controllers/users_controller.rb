class UsersController < ApplicationController

  def edit
    @user = params[:id] ? User.friendly.find(params[:id]) : current_user
  end

  def show
    @user = params[:id] ? User.friendly.find(params[:id]) : current_user
    @user_settings = @user.settings
  end

  def settings
    @user = params[:id] ? User.friendly.find(params[:id]) : current_user
    @user_settings = @user.settings
  end
  
  def update_settings
    updated_key = params[:name].to_sym
    @user = params[:id] ? User.friendly.find(params[:id]) : current_user
    @user_settings = @user.settings

    valid_keys = [:notifications_as_watcher, :notifications_as_collaborator]
    if valid_keys.include?(updated_key)
      @user_settings[updated_key] = params[:value]
      @user_settings.save
    end
    render '/users/settings'
  end
  
  def update
    @user = params[:id] ? User.friendly.find(params[:id]) : current_user
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