class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :authenticate_user!
  
  # Return the type of code to parse based on a file's mime-type
  def code_type_from_mime(mime_type)
    return :ruby
  end

end
