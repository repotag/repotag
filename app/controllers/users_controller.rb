class UsersController < ApplicationController

  def edit
    @user = params[:id] ? User.find(params[:id]) : current_user
  end

  def show
    @user = params[:id] ? User.find(params[:id]) : current_user
  end

  def update
    @user = params[:id] ? User.find(params[:id]) : current_user
    if @user.update_attributes(params[:user])
      redirect_to :action => 'show', :id => @user
    else
      flash_save_errors "user", @user.errors
      render :action => 'edit'
    end
  end
end