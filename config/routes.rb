class GrackAuthProxy  
  def initialize(app)
    @app = app
  end
  
  def call(env)
    @env = env
    if authorized? then
      status, headers, body = @app.call(@env)
      [status, headers, body]
    else
      access_denied
    end
  end
  
  def access_denied
    [403, {"Content-Type" => "text/plain", "WWW-Authenticate" => "Basic realm='Repotag'"}, ["Access Denied"]]
  end
  
  def authorized?
    repo = Repository.from_path(@env['PATH_INFO'])
    return false if repo.nil?
    activity = @env['PATH_INFO'] =~ /(.*?)\/git-receive-pack$/ ? :edit : :read
    return true if repo.public? && activity == :read
    current_user = @env['warden'].user
    return false if current_user.blank?
    return false if !Ability.new(current_user).can?(activity, repo)
    true
  end
end

Repotag::Application.routes.draw do

  resources :repositories

  # resources :repositories do
  #         get :show_file
  #       end

  devise_for :users
  
  authenticated :user do
    mount GrackAuthProxy.new(Grack::App.new({
      :project_root => Repotag::Application.config.datadir,
      :adapter => Grack::RJGitAdapter,
      :upload_pack => true,
      :receive_pack => true,
    })), at: 'git'
  end
  mount proc {|env| [ 401, {"Content-Type" => "text/plain", "WWW-Authenticate" => "Basic realm='Repotag'"}, ["Authorization Required"]]}, at: 'git'
  
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
  
  resource :repositories, :controller => :repositories
  
  root :controller => :repositories, :action => :index
  
  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
