class User < ActiveRecord::Base
  extend FriendlyId
  include SettingConfigurable

  has_many :roles, :dependent => :destroy
  has_many :repositories, :through => :roles, :source => :resource, :source_type => 'Repository'
  friendly_id :username

  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:google_oauth2, :facebook]

  attr_accessor :login, :updating_password

  validates_uniqueness_of :username, :case_sensitive => false
  validates_presence_of :username, :format => {:with => /\A[\w]+\z/ , :message => "contains illegal characters"}
  validates_presence_of :password, :if => :should_validate_password?
  validates :email, :presence => true, :uniqueness => true, :format => {:with => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i , :message => "does not look like an e-mail address"} # Regex from devise, see http://rawsyntax.com/blog/rails-3-email-validation/
  validates :name, :presence => true, :format => {:with => /\A[\w\s]+\z/ , :message => "contains illegal characters"}

  def should_validate_password?
    new_record? || updating_password
  end

  def add_role(title, resource = nil)
    title = title.to_s if title.is_a? Symbol
    r = Role.new
    r.title = title
    r.resource = resource
    roles << r
  end

  def delete_role(title, resource = nil)
    title = title.to_s if title.is_a? Symbol
    query = {:title => title, :user_id => self, :resource_id => nil}
    query[:resource_id] = resource.id unless resource.nil?
    query[:resource_type] = resource.class.to_s unless resource.nil?
    role = Role.where(query).take
    role.destroy if role
  end

  def has_role?(title, resource = nil)
    query = {:title => title, :resource_id => nil}
    query[:resource_id] = resource.id unless resource.nil?
    query[:resource_type] = resource.class.to_s unless resource.nil?
    roles.where(query).take == nil ? false : true
  end

  def admin?
    has_role?(:admin)
  end

  def set_admin(value)
    if !value == admin? then
      if value
        add_role(:admin)
      else
        delete_role(:admin)
      end
    end
  end

  def role_for(resource, include_owner = false)
    return :owner if include_owner && resource.owner == self
    result = roles.where(:resource_id => resource.id, :resource_type => resource.class.to_s).take
    result == nil ? nil : result.title.to_sym
  end

  # Repositories that the user has any role on, other than owner
  def collaborator_repositories(title=nil)
    conditions = {:resource_type => "Repository", :user_id => id}
    conditions[:title] = title unless title.nil?
    Repository.where(:id => Role.where(conditions).select(:resource_id)).to_a
  end

  def watcher_repositories
    collaborator_repositories(:watcher)
  end

  def contributor_repositories
    collaborator_repositories(:contributor)
  end

  def owned_repositories
    Repository.where(:owner_id => self).to_a
  end

  def all_repositories
    collaborator_repositories + owned_repositories
  end

  def self.find_for_auth_provider(access_token)
    data = access_token.info
    user = User.where(:email => data["email"]).first

    unless user
      user = User.create(name: data["name"],
		   email: data["email"],
		   username: data["email"],
		   password: Devise.friendly_token[0,20] )
    end
    user
  end

  singleton_class.send(:alias_method, :find_for_facebook, :find_for_auth_provider)
  singleton_class.send(:alias_method, :find_for_google_oauth2, :find_for_auth_provider)

  def self.default_settings
    {:notifications_as_watcher => true, :notifications_as_collaborator => true}
  end

  protected

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end

end
