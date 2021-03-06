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

  def format_diff(diff_string)
    formatter = Rouge::Formatters::HTML.new(:css_class => 'highlight', :line_numbers => true)
    lexer = Rouge::Lexers::Diff.new
    formatter.format(lexer.lex(diff_string))
  end

  # returns an array of repositories that have not been updated in X days
  def dormant_repos(days)
    Repository.where("updated_at < ?", (Time.now - days.day))
  end

  # RJGit helpers
  def get_listing(repository, path, branch)
    directory_list, file_list = [], []
    ls_options = { :recursive => false, :print => false, :ref => branch }
    path = nil if path.empty?
    lstree = RJGit::Porcelain.ls_tree(repository, path, branch, ls_options)

    if lstree
      lstree.each do |entry|
        last_commit = repository.git.log(entry[:path], branch, options = {max_count: 1}).first
        entry[:name] = ::File.basename(entry[:path])
        entry[:last_commit_message] = last_commit.message
        entry[:last_commit_id] = last_commit.id
        entry[:last_modified] = last_commit.committed_date
        file_list << entry if entry[:type] == 'blob'
        directory_list << entry if entry[:type] == 'tree'
      end
    end
    return directory_list, file_list
  end
    

end
