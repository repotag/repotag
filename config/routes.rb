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

  project_root = Setting.get(:general_settings)[:repo_root] || GENERAL_DEFAULTS[:repo_root]

  r = RepotagAuthProxy.new(true)

  grack_auth_proxy = RepotagAuthProxy.new(Grack::App.new({
      :project_root => project_root,
      :adapter => Grack::RJGitAdapter,
      :upload_pack => true,
      :receive_pack => true,
  }))

  gollum_auth_proxy = GollumAuthProxy.new(project_root, :markdown, {:universal_toc => false, :live_preview => false})

  authenticated :user do
    mount grack_auth_proxy, at: 'git', as: 'git'
    mount gollum_auth_proxy, at: ':user/:repository/wiki'
    match '/:user/:repository/wiki', to: gollum_auth_proxy, via: [:get, :post], as: 'wiki'
    get '/:user/settings', controller: 'users', action: 'settings'
    put '/:user/update_settings', controller: 'users', action: 'update_settings'
    
  end
  mount grack_auth_proxy, at: 'git'
  mount gollum_auth_proxy, at: 'wiki'

  root :controller => :repositories, :action => :index

  resources :users, :only => [:show, :edit, :update], :path => ''
  resources :users, :only => [], :path => '' do
    resources :repositories, :controller => 'repositories', :path => '' do
      get 'get_children', on: :member
      get 'settings', :controller => 'repositories', :action => :settings
      get 'select_users', :controller => 'repositories', :action => :potential_users
      put 'settings', :controller => 'repositories', :action => :update_settings
      put 'add_collaborator'
      put 'remove_collaborator'
    end
  end

end
