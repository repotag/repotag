class Admin::AdminController < ApplicationController
  layout 'admin'
  before_filter :verify_admin

  def verify_admin
    authenticate_user!
    redirect_to root_url, :alert => "You are not authorized to access the admin area." unless current_user.admin?
  end

  def current_ability
    @current_ability ||= Ability.new(current_user)
  end
end