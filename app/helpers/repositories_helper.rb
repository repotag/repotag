module RepositoriesHelper
  
  def image_for_file(file)
    type = File.extname(file.to_s).sub(/^\./, '')
    if Rails.configuration.filetypes_with_image.include?(type)
      image = "#{type}.png"
    else 
      image = case file.type
        when :directory then 'folder.png'
        when :file then 'file.png'
        else 'file.png'
      end
    end
    return "fileicons/#{image}"
  end
  
  # returns an array of repositories that have not been updated in X days
  def dormant_repos(days)   
    Repository.where("updated_at < ?", (Time.now - days.day))
  end   
  
  def nav_link(link_text, link_path)
    class_name = current_page?(link_path) ? 'active' : nil

    content_tag(:li, :class => class_name) do
      link_to link_text, link_path
    end
  end
  
  # return all repos of a user with a certain role (default is all roles)
  #def repos_of_user(username, role=:all)
    #roles = Rails.configuration.role_titles
    #Repository.where(user: username, role: role)
  #end

end
