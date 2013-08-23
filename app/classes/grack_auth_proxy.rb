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