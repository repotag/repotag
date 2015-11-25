class RepositoriesController < ApplicationController
  before_filter :find_user_repository, :except => [:index, :new, :create]
  load_and_authorize_resource
  skip_authorize_resource :only => [:settings, :update_settings, :add_collaborator, :remove_collaborator, :potential_users]
  skip_load_resource :only => [:index, :create]

  include Params::RepoParams
  include UpdateSettings

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

    @general_settings = Setting.get(:general_settings)
    uri_class = @general_settings[:ssl_enabled] ? URI::HTTPS : URI::HTTP
    @clone_url = uri_class.build(:host => @general_settings[:server_domain], :port => @general_settings[:server_port].to_i, :path => "/git/#{@repository.owner.username}/#{@repository.name}")
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
        if readme_filename
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
    path = params[:path].empty? ? nil : params[:path]
    repo = @repository.repository
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

  def create
    @repository = Repository.new(repo_params)
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

  def update
    respond_to do |format|
      if @repository.update_attributes(repo_params)
        format.html { redirect_to [@repository.owner, @repository], notice: 'Repository was successfully updated.' }
        format.json { head :no_content }
      else
        flash_save_errors "repository", @repository.errors
        format.html { render action: "edit" }
        format.json { render json: @repository.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @repository.destroy

    respond_to do |format|
      format.html { redirect_to repositories_url, notice: "Repository was successfully deleted." }
      format.json { head :no_content }
    end
  end
  
  def toggle_public
    authorize! :update, @repository
    @repository.public = ActiveRecord::Type::Boolean.new.type_cast_from_user(repo_params[:public])
    @repository.save
    render :nothing => true
  end
  
  def settings
    authorize! :update, @repository
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
    authorize! :update, @repository
    potential_contributors = User.where.not(id: @repository.contributing_users + @repository.collaborating_users + [@repository.owner]).where(:public => true).select(:username).to_a.map {|x| {:name => x[:username]}}
    respond_to do |format|
      format.json { render :json => potential_contributors }
    end
  end
  
  def update_settings
    authorize! :update, @repository
    @repository_settings = save_settings(@repository)
    @collaborators = @repository.collaborating_users
    @contributors = @repository.contributing_users
    @general_settings = Setting.get(:general_settings)
    render "repositories/settings"
  end
  
  def add_collaborator
    authorize! :update, @repository
    role = params[:role]
    user = User.friendly.find(params[:username])
    
    respond_to do |format|
    if user.has_role?(params[:role], @repository)
      # User has role already. Ignore (should not really happen)
      format.json {render json: {} }
    else
      # Try adding the role
      user.add_role(role, @repository)
      if user.has_role?(params[:role], @repository)
        # Return user to be added to the table
        format.json {render json: {:user => user, delete_url: user_repository_remove_collaborator_path(@repository.owner, @repository, :collaborator_id => user.id, :role => :contributor) }}
      else
        # Failure to add role
        format.json {render json: {} }
      end
    end
  end
    
  end
  
  def remove_collaborator
    authorize! :update, @repository
    role = params[:role]
    collaborator = User.find(params[:collaborator_id])

    collaborator.delete_role(role, @repository)
    
    @collaborators = @repository.collaborating_users
    @contributors = @repository.contributing_users
    @repository_settings = @repository.settings
    @general_settings = Setting.get(:general_settings)
    
    render "repositories/settings"
  end

  private

  def find_user_repository
    if params[:repository_id] then
      repo = params[:repository_id]
    else
      repo = params[:id]
    end
    @repository = Repository.where(:owner_id => User.friendly.find(params[:user_id])).friendly.find(repo)
  end

  def prepare_fileview(repository, branch)
    blob = repository.blob(params[:path], branch)
    raise if blob == nil
    formatter = Rouge::Formatters::HTML.new(:css_class => 'highlight', :line_numbers => true)
    lexer = Rouge::Lexer.guess({:mimetype => blob.mime_type, :filename => blob.name, :source => blob.data})
    lexer = Rouge::Lexers::PlainText.new unless lexer
    formatter.format(lexer.lex(blob.data))
  end
  
  def send_confirmation_email(repository)
    HookMailer.repository_created(repository.owner, repository).deliver_now
  end

  def get_readme_filename(file_list)
    filenames = file_list.map{|file| file[:path] }
    filenames.keep_if{|name| name =~ /^readme\..*$/i }.first
  end
  
  def get_readme_content(readme_filename, repository)
    repository.blob(readme_filename).data
  end

end
