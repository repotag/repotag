Repotag::Application.routes.draw do

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  get '/repositories', :controller => 'repositories', :action => :index
  get '/users', :controller => 'users', :action => :index

  namespace :admin do
  	get '/' => 'users#index'
  	resources :users
    resources :repositories, :except => :create do
      put 'archive'
      put 'unarchive'
    end

    get '/settings/general', :controller => 'settings', :action => :show_general_settings
    put '/settings/general', :controller => 'settings', :action => :update_general_settings

    get '/settings/authentication', :controller => 'settings', :action => :show_authentication_settings
    put '/settings/authentication', :controller => 'settings', :action => :update_authentication_settings

    resources :settings, only: []
    get '/email/smtp', :controller => 'settings', :action => :show_smtp_settings
    put '/email/smtp', :controller => 'settings', :action => :update_smtp_settings
    post '/email/smtp', :controller => 'settings', :action => :send_test_mail
	end

  grack_auth_proxy = RepotagAuthProxy.new({
      :adapter => Grack::RJGitAdapter,
      :allow_push => true,
      :allow_pull => true,
      :git_adapter_factory => ->{ Grack::RJGitAdapter.new }
  })

  gollum_auth_proxy = GollumAuthProxy.new(:markdown, {:universal_toc => false, :live_preview => false})

  authenticated :user do
    mount grack_auth_proxy, at: 'git', as: 'git'
    get '/:id/settings', controller: 'users', action: 'settings'
    put '/:id/update_settings', controller: 'users', action: 'update_settings'
  end
  mount grack_auth_proxy, at: 'git'
  mount gollum_auth_proxy, at: ':user/:repository/wiki'
  match '/:user/:repository/wiki', to: gollum_auth_proxy, via: [:get, :post], as: 'wiki'
  
  root :controller => :repositories, :action => :index

  resources :users, :only => [:show, :edit, :update], :path => ''
  resources :users, :only => [], :path => '' do
    resources :repositories, :controller => 'repositories', :path => '' do
      get 'get_children', on: :member
      get 'settings', :controller => 'repositories', :action => :settings
      get 'select_users', :controller => 'repositories', :action => :potential_users
      put 'settings', :controller => 'repositories', :action => :update_settings
      get '/commit/:sha', controller: 'repositories', action: :show, as: :commit
      put 'add_collaborator'
      put 'remove_collaborator'
      put 'toggle_public'
    end
  end

end
