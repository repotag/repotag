class RepositoriesController < ApplicationController
  load_and_authorize_resource
  skip_authorize_resource :only => [:new, :create]

  def find_user_repository(user_name, repository_name)
    Repository.where(:owner_id => User.friendly.find(user_name)).friendly.find(repository_name)
  end

  # GET /repositories
  # GET /repositories.json
  def index
    if current_user
      @repositories = current_user.all_repositories
    else
      @repositories = Repository.where(:public => true)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @repositories }
    end
  end

  # GET /repositories/1
  # GET /repositories/1.json
  def show
    @repository = find_user_repository(params[:user_id], params[:id])
        
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

    @general_settings = Setting.get(:general_settings)
    @clone_url = URI::HTTP.build(:host => @general_settings[:server_domain], :port => @general_settings[:server_port].to_i, :path => "/git/#{@repository.owner.username}/#{@repository.name}")
    @active_nav_tab = :code

    @commit = RJGit::Commit.find_head(repository)

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
      @directory_list, @file_list = view_context.get_listing(repository, branch, tree)
      
      unless params[:file] || params[:path]
        # get the first readme file
        readme_filename = get_readme_filename(@file_list)
        if read_filename
          readme_content = get_readme_content(readme_filename, repository)
          @readme_html = GitHub::Markup.render(readme_filename, readme_content)
        end
      end
      
    end
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @repository }
    end

  end

  def get_children
    repository = find_user_repository(params[:user_id], params[:id])
    path = params[:path].empty? ? nil : params[:path]
    repo = repository.repository
    branch = params[:branch] || "refs/heads/master"
    begin
      tree = repo.tree(path, branch)
    rescue
      raise ActionController::RoutingError.new("Oops! Could not find the object '#{path}'.")
    end
    @directory_list, @file_list = [], []
    ls_options = { :recursive => false, :print => false, :branch => branch }
    lstree = RJGit::Porcelain.ls_tree(repo, tree, ls_options)

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

    respond_to do |format|
      format.json { render json: {:dirs => @directory_list, :files => @file_list} }
    end
  end

  def prepare_fileview(repository, branch)
    blob = repository.blob(params[:path], branch)
    raise if blob == nil
    formatter = Rouge::Formatters::HTML.new(:css_class => 'highlight', :line_numbers => true)
    lexer = Rouge::Lexer.guess({:mimetype => blob.mime_type, :filename => blob.name, :source => blob.data})
    lexer = Rouge::Lexers::PlainText.new unless lexer
    formatter.format(lexer.lex(blob.data))
  end

  def get_readme_filename(file_list)
    filenames = file_list.map{|file| file[:path] }
    filenames.keep_if{|name| name =~ /^readme\..*$/i }.first
  end
  
  def get_readme_content(readme_filename, repository)
    Rails.logger.debug "trying to get content"
    repository.blob(readme_filename).data
  end

  # GET /repositories/new
  # GET /repositories/new.json
  def new
  end

  # GET /repositories/1/edit
  def edit
  end

  # POST /repositories
  # POST /repositories.json
  def create
    @repository = Repository.new(params[:repository])
    @repository.owner = current_user
    respond_to do |format|
      if @repository.save && @repository.to_disk
        @repository.initialize_readme
        send_confirmation_email(@repository)
        format.html { redirect_to [@repository.owner, @repository], notice: 'Repository was successfully created.' }
        format.json { render json: @repository, status: :created, location: @repository }
      else
        flash_save_errors "repository", @repository.errors
        format.html { render action: "new" }
        format.json { render json: @repository.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /repositories/1
  # PUT /repositories/1.json
  def update
    respond_to do |format|
      if @repository.update_attributes(params[:repository])
        format.html { redirect_to [@repository.owner, @repository], notice: 'Repository was successfully updated.' }
        format.json { head :no_content }
      else
        flash_save_errors "repository", @repository.errors
        format.html { render action: "edit" }
        format.json { render json: @repository.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /repositories/1
  # DELETE /repositories/1.json
  def destroy
    @repository.destroy

    respond_to do |format|
      format.html { redirect_to repositories_url }
      format.json { head :no_content }
    end
  end
  
  def show_repository_settings
    @repository = find_user_repository(params[:user_id], params[:repository_id])
    @collaborators = @repository.collaborating_users
    @contributors = @repository.contributing_users
    @repository_settings = @repository.settings
    @general_settings = Setting.get(:general_settings)
    @active_nav_tab = :settings
    respond_to do |format|
      format.html { render 'repositories/settings'}
      format.json { render :json => @repository_settings }
    end
  end

  def potential_users
    @repository = find_user_repository(params[:user_id], params[:repository_id])
    potential_contributors = User.where.not(id: @repository.contributing_users + @repository.collaborating_users + [@repository.owner]).where(:public => true).select(:username).to_a.map {|x| {:name => x[:username]}}
    respond_to do |format|
      format.json { render :json => potential_contributors }
    end
  end
  
  def update_repository_settings
    @repository = find_user_repository(params[:user_id], params[:repository_id])
    updated_key = params[:name].to_sym
    valid_keys = [:enable_wiki, :enable_issuetracker, :default_branch]
    if valid_keys.include?(updated_key)
      settings = @repository.settings
      settings[updated_key] = params[:value]
      settings.save
    end
    @collaborators = @repository.collaborating_users
    @contributors = @repository.contributing_users
    @repository_settings = @repository.settings
    
    render "repositories/settings"
  end
  
  def add_collaborator
    role = params[:role]
    @user = User.find_by_username(params[:username])
    @repository = find_user_repository(params[:user_id], params[:repository_id])
    
    respond_to do |format|
    if @user.has_role?(params[:role], @repository)
      # User has role already. Ignore (should not really happen)
      format.json {render json: {} }
    else
      # Try adding the role
      @user.add_role(role, @repository)
      if @user.has_role?(params[:role], @repository)
        # Return user to be added to the table
        format.json {render json: {:user => @user, delete_url: user_repository_remove_collaborator_path(@repository.owner, @repository, :collaborator_id => @user.id, :role => :contributor) }}
      else
        # Failure to add role
        format.json {render json: {} }
      end
    end
  end
    
  end
  
  def remove_collaborator
    role = params[:role]
    collaborator = User.find(params[:collaborator_id])
    @repository = find_user_repository(params[:user_id], params[:repository_id])
    collaborator.delete_role(role, @repository)
    
    @collaborators = @repository.collaborating_users
    @contributors = @repository.contributing_users
    @repository_settings = @repository.settings
    @general_settings = Setting.get(:general_settings)
    
    render "repositories/settings"
  end
  
  def send_confirmation_email(repository)
    HookMailer.repository_created(repository.owner, repository).deliver_now
  end
  
end
