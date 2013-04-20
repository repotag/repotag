require 'activemodelwrapper'

ActiveAdmin.register Repository do
  
  actions :index, :show, :new, :create
  # render active_admin_template('edit.html.arb'), :layout => false
  
  # controller do
  #       def index
  #         @testvar = "Test"
  #             
  #       # render :partial => 'index_partial'
  #       # render 'index_partial'
  #       end            
  #     end
  
  menu :label => "Repository Browser"
  
  member_action :show_file do
    #@current_path = params[:path]
    #@rendered_text = CodeRay.scan_file(@current_path).div
    #render :partial => "show_file", :locals => {:testvar => @testvar }
  end
  
  controller do
    
    helper :repositories
        
    # Needs input sanitation! 
    # http://localhost:3000/repositories/1?file=true&path=%2Fetc%2Fpasswd shows
    # /etc/passwd.
    
    def show
      if params[:file]
        @current_path = params[:path]
        @rendered_text = CodeRay.scan_file(@current_path).div
      else
        @repo = Repository.find(params[:id])
        path = params[:path] != nil ? params[:path] : Repository.path(@repo)
        @data = directory_hash(path)
        @current_path = @data[:data]
        @directory_list = []
        @files_list = []

        @data[:children].each do |item|
          item.is_a?(Hash) ? @directory_list << item[:data] : @files_list << item
        end
        @listing = []
        @listing << @directory_list.map{|dir| ActiveModelWrapper.new(:name => dir, :type => :directory) }
        @listing << @files_list.map{|file| ActiveModelWrapper.new(:name => file, :type => :file) }
        @listing.flatten!
      end
    end


    def create
      create! {}
    end
  end
  
  index do
    column :id
    column :name, :sortable => :name do |repo|
      link_to repo.name, repository_path(repo.id)
    end
    default_actions
    #render active_admin_template('edit.html.arb'), :layout => false
    div do
      render :partial => "index", :locals => {:testvar => @testvar }
    end
  end

  show :title => :name do |repository|
    
    #h1 repository.name
    if params[:file]
      div do
        render :partial => 'show'
      end
    else
      panel "#{current_path}" do
        table_for(listing) do |t|
          t.column("") do |file|
            image = image_for_file(file)
            image_tag(image) 
          end
          t.column("") do |file| 
            if file.type == :directory
              link_to file.name, repository_path(repo,:path=>current_path+'/'+file.to_s)
            else
              link_to file.name, repository_path(repo,:path=>current_path+'/'+file.to_s, :file => true)
            end
          end
        end
      end
    end
  end
  
  
end
