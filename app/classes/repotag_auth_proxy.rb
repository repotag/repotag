require 'gollum/app'

class RepotagAuthProxy
  def initialize(app)
    @app = app
  end

  def call(env)
    @env = env
    base_path = @env['PATH_INFO'].match(/^\/[\w]+\/[\w]+/).to_s
    return not_found if base_path == ""
    repository = find_repository(base_path)
    return not_found if repository.nil?
    user = authenticated?
    if user.blank? then
      return not_authenticated if !authorized?(repository, user)
    elsif !authorized?(repository, user) then
      return access_denied
    end
    @env['PATH_INFO'] = "/#{repository.filesystem_name}#{@env['PATH_INFO'][base_path.length..@env['PATH_INFO'].length]}"
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

  def find_repository(path)
    Repository.from_request_path(path)
  end

  def authorized?(repository, user)
    activity = @env['PATH_INFO'] =~ /(.*?)\/git-receive-pack$/ ? :edit : :read
    return true if repository.public? && activity == :read
    return false if !Ability.new(user).can?(activity, repository)
    return true
  end
end

class Precious::App
  before do
    if env['authorName'] then
      session['gollum.author'] = {
        :name => env['authorName'],
        :email => env['authorEmail'] || ""
      }
    end
  end
end

class GollumAuthProxy < RepotagAuthProxy
  def initialize(root, markup, wiki_options = {})
    @markup = markup
    @wiki_options = wiki_options
    @repo_root = root
  end

  def call(env)
    @env = env
    request = Rack::Request.new(@env)
    base_path = request.fullpath.to_s
    return not_found if base_path == ""
    repository = find_repository(base_path)
    return not_found if repository.nil?
    user = authenticated?
    priviliges = authorized?(repository, user)
    if user.blank? then
      return not_authenticated if !priviliges
    elsif !priviliges then
      return access_denied
    elsif priviliges == :edit
      @env['authorName'] = user.name
      @env['authorEmail'] = user.email
    end
    options = {
      :gollum_path => ::File.join(@repo_root, repository.filesystem_name),
      :default_markup => @markup,
      :wiki_options => @wiki_options.merge({:allow_editing => priviliges == :edit})
    }
    status, headers, body = MapGollum.new(base_path, options).call(@env)
    [status, headers, body]
  end

  def authorized?(repository, user)
    ability = Ability.new(user)
    return :edit if ability.can?(:edit, repository)
    return :read if ability.can?(:read, repository)
    false
  end

  class MapGollum
    # See https://github.com/gollum/gollum/wiki/Using-Gollum-with-Rack#the---base-path-option
    
    def initialize(base_path, options)
      @mg = Rack::Builder.new do
        map "/" do
          options.each do |option, value|
            Precious::App.set(option, value)
          end
          run Precious::App
        end
      end
    end

    def call(env)
      @mg.call(env)
    end
  end
end