class UsersController < ApplicationController 
 
  def edit
    @user = params[:id] ? User.find(params[:id]) : current_user
  end
  
  def show
    @user = params[:id] ? User.find(params[:id]) : current_user
  end
end