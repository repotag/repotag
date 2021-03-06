class Admin::UsersController < Admin::AdminController
  load_and_authorize_resource :except => [:index, :new, :create]

  include Params::UserParams

  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @users }
    end
  end

  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @user }
    end
  end

  def new
    @user = User.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @user }
    end
  end

  def create
    @user = User.new(user_params)
    set_user_roles(@user, params["global_roles"])

    respond_to do |format|
      if @user.save
        format.html { redirect_to admin_users_path, :notice => 'User was successfully created.' }
        format.json { render :json => @user, :status => :created, :location => @user }
      else
        flash_save_errors "user", @user.errors
        format.html { render :new }
        format.json { render :json => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    update_params = user_params.dup
    if update_params[:password].blank?
      update_params.delete(:password)
      update_params.delete(:password_confirmation)
    end
    set_user_roles(@user, params["global_roles"])

    respond_to do |format|
      if @user.update_attributes(update_params)
        format.html { redirect_to admin_users_path, :notice => 'User was successfully updated.' }
        format.json { head :ok }
      else
        flash_save_errors "user", @user.errors
        format.html { render :edit }
        format.json { render :json => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @user.destroy

    respond_to do |format|
      format.html { redirect_to admin_users_url }
      format.json { head :ok }
    end
  end

  private

  def set_user_roles(user, roles)
    unless roles.nil?
      roles.each do |role|
        user.add_role(role)
      end
    end
  end

end