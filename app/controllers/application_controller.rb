class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :authenticate_user! unless Setting.get(:general_settings)[:anonymous_access]

  layout 'application'

  # Set flashes for saving errors
  def flash_save_errors(type, errors)
    msg = ""
    errors.full_messages.each {|err| msg << "<li>#{err}</li>"}
    flash.now.alert = "#{ActionController::Base.helpers.pluralize(errors.count, 'error')} prevented this #{type} from being saved:<ul>#{msg}</ul>".html_safe
  end

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
