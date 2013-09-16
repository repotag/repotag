class RepositoriesController < ApplicationController
  load_and_authorize_resource
  # GET /repositories
  # GET /repositories.json
  def index
    @repositories = Repository.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @repositories }
    end
  end

  # GET /repositories/1
  # GET /repositories/1.json
  def show
    if @repository.invalid? then
      flash[:alert] = "Repository #{@repository.name} is invalid."
      redirect_to :action => :index
      return false
    end
    
    @current_path = params[:path].nil? ? '' : params[:path]
    repository = @repository.repository
    
    if !repository.valid?
      flash[:alert] = "Repository #{@repository.name} does not seem to have a valid git repository."
      redirect_to :action => :index
      return false
    end
    
    branch = params[:branch] || "refs/heads/master"
    if params[:file]
      begin
        @rendered_text = prepare_fileview(repository, branch)
      rescue
        flash[:alert] = "Blob #{@current_path} not found in branch #{branch}."
        redirect_to :action => :show, :branch => branch       
        return false
      end
    else
      begin
        tree = @current_path.empty? ? nil : repository.tree(@current_path, branch)
        raise if tree.nil? && !@current_path.empty? 
      rescue
        flash[:alert] = "Path #{@current_path} not found in branch #{branch}."
        redirect_to :action => :show, :branch => branch
        return false
      end
      @directory_list, @file_list = [], []
      ls_options = { :recursive => false, :print => false, :branch => branch }
      lstree = RJGit::Porcelain.ls_tree(repository, tree, ls_options)
    
      if lstree
        lstree.each do |entry| 
          @file_list << entry if entry[:type] == 'blob' 
          @directory_list << entry if entry[:type] == 'tree'
        end
      end
    end
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @repository }
    end       

  end

  def get_children
    repository = Repository.find(params[:id])
    path = params[:path].empty? ? nil : params[:path]
    repo = repository.repository
    branch = params[:branch] || "refs/heads/master"
    begin
      tree = repo.tree(path, branch)
      Rails.logger.debug "Tree for #{path}: #{tree.inspect}"
    rescue
      raise ActionController::RoutingError.new("Oops! Could not find the object '#{path}'.")
    end
    @directory_list, @file_list = [], []
    ls_options = { :recursive => false, :print => false, :branch => branch }
    lstree = RJGit::Porcelain.ls_tree(repo, tree, ls_options)
    
    Rails.logger.debug "lstree: #{lstree}"   
    if lstree
      lstree.each do |entry| 
        if entry[:type] == 'blob'
          entry[:image] = view_context.image_for_file(entry[:path])
          entry[:fullpath] = File.join(path, entry[:path])
          @file_list << entry
        end
        @directory_list << entry if entry[:type] == 'tree'
      end
    end
    Rails.logger.debug "files: #{@file_list}"
    Rails.logger.debug "dirs: #{@directory_list}"
    respond_to do |format|
      format.json { render json: {:dirs => @directory_list, :files => @file_list} }
    end
  end

  def prepare_fileview(repository, branch)
    blob = repository.blob(params[:path], branch)
    raise if blob == nil
    CodeRay.scan(blob.data, code_type_from_mime(blob.mime_type)).div
  end

  # GET /repositories/new
  # GET /repositories/new.json
  def new
    @repository = Repository.new
    @repository.owner = current_user

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @repository }
    end
  end

  # GET /repositories/1/edit
  def edit
    @repository = Repository.find(params[:id])
  end

  # POST /repositories
  # POST /repositories.json
  def create
    @repository = Repository.new(params[:repository])
    @repository.owner = current_user
    respond_to do |format|
      if @repository.save
        format.html { redirect_to @repository, notice: 'Repository was successfully created.' }
        format.json { render json: @repository, status: :created, location: @repository }
      else
        format.html { render action: "new" }
        format.json { render json: @repository.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /repositories/1
  # PUT /repositories/1.json
  def update
    @repository = Repository.find(params[:id])

    respond_to do |format|
      if @repository.update_attributes(params[:repository])
        format.html { redirect_to @repository, notice: 'Repository was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @repository.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /repositories/1
  # DELETE /repositories/1.json
  def destroy
    @repository = Repository.find(params[:id])
    @repository.destroy

    respond_to do |format|
      format.html { redirect_to repositories_url }
      format.json { head :no_content }
    end
  end
end
