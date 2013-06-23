class GrackAuthProxy  
  def initialize(app)
    @app = app
  end
  
  def call(env)
    @env = env
    repository = find_repository
    return not_found if repository.nil?
    user = authenticated?
    if user.blank? then
      return not_authenticated if !authorized?(repository, user)
    elsif !authorized?(repository, user) then
      return access_denied
    end
    status, headers, body = @app.call(@env)
    [status, headers, body]
  end
  
  def not_authenticated
    [401, {"Content-Type" => "text/plain", "WWW-Authenticate" => "Basic realm='Repotag'"}, ["Unauthorized"]]
  end
  
  def access_denied
    [403, {"Content-Type" => "text/plain"}, ["Access Denied"]]
  end
  
  def not_found
    [404, {"Content-Type" => "text/plain"}, ["Not Found"]]
  end
  
  def authenticated?
     @env['warden'].user
  end
  
  def find_repository
    Repository.from_path(@env['PATH_INFO'])
  end
  
  def authorized?(repository, user)
    activity = @env['PATH_INFO'] =~ /(.*?)\/git-receive-pack$/ ? :edit : :read
    return true if repository.public? && activity == :read
    return false if !Ability.new(user).can?(activity, repository)
    return true
  end
end

Repotag::Application.routes.draw do

  resources :repositories

  # resources :repositories do
  #         get :show_file
  #       end

  devise_for :users
  
  # Allow users to edit their own info
  resources :users
  
  grack_auth_proxy = GrackAuthProxy.new(Grack::App.new({
      :project_root => Repotag::Application.config.datadir,
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
