class Admin::RepositoriesController < Admin::AdminController
  load_and_authorize_resource
  # GET /repositories
  # GET /repositories.json
  def index
    @repositories = Repository.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @repositories }
    end
  end

  # GET /repositories/1
  # GET /repositories/1.json
  def show
      redirect_to [@repository.owner, @repository]
  end

  # GET /repositories/new
  # GET /repositories/new.json
  def new
    @repository = Repository.new

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

    respond_to do |format|
      if @repository.save
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
    @repository = Repository.find(params[:id])

    respond_to do |format|
      if @repository.update_attributes(params[:repository])
        format.html { redirect_to [@repository.owner, @repository], notice: 'Repository was successfully updated.' }
        format.json { head :no_content }
        format.js { flash[:notice] = 'Repository was updated.'}
      else
        flash_save_errors "repository", @repository.errors
        format.html { render action: "edit" }
        format.json { render json: @repository.errors, status: :unprocessable_entity }
      end
    end
  end

  def archive
    @repository = Repository.find(params[:repository_id])
    if @repository.repository.valid?
      respond_to do |format|
        if Tarchiver::Archiver.archive(@repository.repository.path, Setting.get(:general_settings)[:archive_root], {delete_input_on_success: true})
          @repository.archived = true
          @repository.archived_at = DateTime.current
          @repository.save
          format.html { redirect_to action: 'index', notice: 'Repository was archived.'}
        else
          format.html {redirect_to action: 'index', notice: 'Repository could not not be archived.'}
        end
    end
    
      
    end #render 'index', notice: 'Repository was archived.'
  end
  
  def unarchive
    @repository = Repository.find(params[:repository_id])
    archive = File.join(Setting.get(:general_settings)[:archive_root], "#{@repository.filesystem_name}.tgz")
    respond_to do |format|
      if Archiver.unarchive(archive, Setting.get(:general_settings)[:repo_root], {delete_input_on_success: true})
        @repository.archived = false
        @repository.save
        format.html { redirect_to action: 'index', notice: 'Repository was restored.'}
      else
        format.html { redirect_to action: 'index', notice: 'Repository could not be restored.'}
      end
    end
  end

  # DELETE /repositories/1
  # DELETE /repositories/1.json
  def destroy
    @repository = Repository.find(params[:id])
    @repository.destroy

    respond_to do |format|
      format.html { redirect_to admin_repositories_url, notice: "Repository #{@repository.name} was successfully deleted." }
      format.json { head :no_content }
    end
  end
end
