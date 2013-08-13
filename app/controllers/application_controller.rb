class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :authenticate_user!
  
  # Return the type of code to parse based on a file's mime-type
  def code_type_from_mime(mime_type)
    return :ruby
  end

  def has_role?(current_user, role)
    #return !!current_user.roles.find_by_title(role.to_s.camelize)
    return !!current_user.roles.find_by_title(role.to_sym)
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end
end
