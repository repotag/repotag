module RepositoriesHelper
  
  def image_for_file(file, dir = false)
    return "/assets/fileicons/folder.png" if dir
    type = File.extname(file.to_s).sub(/^\./, '')
    if known_filetypes.include?(type)
      image = "#{type}.png"
    else 
      image = 'file.png'
    end
    return "/assets/fileicons/#{image}"
  end
  
  def known_filetypes
    types = Array.new
    Dir.glob(File.join(Rails.root, "/app/assets/images/fileicons/*.png")).each do |f|
      types << File.basename(f, '.png')
    end
    return types
  end
  
  
  # returns an array of repositories that have not been updated in X days
  def dormant_repos(days)
    Repository.where("updated_at < ?", (Time.now - days.day))
  end

end
