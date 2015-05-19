Repotag::Application.routes.draw do

  resources :repositories do
    get 'get_children', on: :member
    get 'settings', :controller => 'repositories', :action => :show_repository_settings
    put 'settings', :controller => 'repositories', :action => :update_repository_settings
    # get 'wiki', :controller => 'repositories'
    put 'add_collaborator'
    put 'remove_collaborator'
  end

  # resources :repositories do
  #         get :show_file
  #       end

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  # Allow users to edit their own info
  resources :users, only: [:index, :show, :edit, :update]

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
      grack_project_root = Setting.get(:general_settings)[:repo_root]
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

#Working on the Google authentication (https://github.com/plataformatec/devise/wiki/OmniAuth%3A-Overview) Working on the callback
#, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.

  root :controller => :repositories, :action => :index

  # See how all your routes lay out with "rake routes"

end
