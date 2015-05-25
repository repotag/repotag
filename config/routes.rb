Repotag::Application.routes.draw do

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  get '/repositories', :controller => 'repositories', :action => :index
  get '/users', :controller => 'users', :action => :index

  namespace :admin do
  	get '/' => 'users#index'
  	resources :users
    get '/users/:id/set_admin', :controller => 'admin/users', :action => :set_admin
    resources :repositories

    get '/settings/general', :controller => 'settings', :action => :show_general_settings
    put '/settings/general', :controller => 'settings', :action => :update_general_settings

    get '/settings/authentication', :controller => 'settings', :action => :show_authentication_settings
    put '/settings/authentication', :controller => 'settings', :action => :update_authentication_settings

    resources :settings, only: []
    get '/email/smtp', :controller => 'settings', :action => :show_smtp_settings
    put '/email/smtp', :controller => 'settings', :action => :update_smtp_settings
    post '/email/smtp', :controller => 'settings', :action => :send_test_mail
	end

  begin
      grack_project_root = general_setting(:repo_root)
    rescue
      grack_project_root = nil
  end

  grack_auth_proxy = GrackAuthProxy.new(Grack::App.new({
      :project_root => grack_project_root,
      :adapter => Grack::RJGitAdapter,
      :upload_pack => true,
      :receive_pack => true,
    }))

  authenticated :user do
    mount grack_auth_proxy, at: 'git'
  end
  mount grack_auth_proxy, at: 'git'

  root :controller => :repositories, :action => :index

  resources :users, :only => [:show, :edit, :update], :path => ''
  resources :users, :only => [], :path => '' do
    resources :repositories, :controller => 'repositories', :path => '' do
      get 'get_children', on: :member
      get 'settings', :controller => 'repositories', :action => :show_repository_settings
      get 'select_users', :controller => 'repositories', :action => :potential_users
      put 'settings', :controller => 'repositories', :action => :update_repository_settings
      put 'add_collaborator'
      put 'remove_collaborator'
    end
  end

end
