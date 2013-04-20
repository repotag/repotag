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
    #params[:path] = params[:path]
    #@rendered_text = CodeRay.scan_file(params[:path]).div
    #render :partial => "show_file", :locals => {:testvar => @testvar }
  end
  
  controller do
    
    helper :repositories
    
    def show
      @current_path = params[:path]
      @repo = Repository.find(params[:id])
      repository = @repo.repository
      if params[:file] then
        begin
          blob = repository.blob(params[:path])
        rescue
          raise ActionController::RoutingError.new("Oops! Could not find the object '#{params[:path]}'.")
        end
        @rendered_text = CodeRay.scan(blob.data, code_type_from_mime(blob.mime_type)).div
      else
        begin
          tree = params[:path] ? repository.tree(params[:path]) : nil
        rescue
          raise ActionController::RoutingError.new("Oops! Could not find the object '#{params[:path]}'.")
        end
        @listing = []
        ls_options = { :recursive => false, :print => false }
        ls_options[:branch] = params[:branch] if params[:branch]
        RJGit::Porcelain.ls_tree(repository, tree, ls_options).each {|x| @listing << ActiveModelWrapper.new(:name => x[:path], :type => x[:type].to_sym) }
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
      panel "#{repo.name}/#{params[:path]}" do
        table_for(listing) do |t|
          t.column("") do |file|
            image = image_for_file(file)
            image_tag(image) 
          end
          t.column("") do |file|
            puts params[:path].inspect
            path = params[:path] == nil ? file.to_s : "#{params[:path]}/#{file.to_s}"
            puts path.inspect
            if file.type == :tree
              link_to file.name, repository_path(repo, :path => path)
            else
              link_to file.name, repository_path(repo, :path => path, :file => true)
            end
          end
        end
      end
    end
  end
  
  
end
