module ApplicationHelper
  
  # Create link for navbar
  def nav_link(link_text, link_path, class_name = [], options = {})
    class_name << 'active' if current_page?(link_path)

    content_tag(:li, :class => [class_name].join(" ")) do
      link_to link_text, link_path, options
    end
  end
  
  # Return flash class for name of FlashHash
  def flash_class(name)
    "alert " + case name
    when :alert
      "alert-warning"
    when :notice
      "alert-info"
    when :success
      "alert-success"
    when :error
      "alert-danger"
    else "alert-warning"
    end
  end
  
  # Pretty indication of the user's roles (including global roles and ownership) on a resource
  def role_description(resource, user = current_user)
    return [:public] unless user
    result = []
    result << :admin if user.admin?
    role = user.role_for(resource, true) 
    result << role if role
    result
  end
  
end
