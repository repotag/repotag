class UsersController < ApplicationController

  def edit
    @user = params[:id] ? User.friendly.find(params[:id]) : current_user
  end

  def show
    @user = params[:id] ? User.friendly.find(params[:id]) : current_user
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