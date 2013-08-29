class User < ActiveRecord::Base
 
  has_many :roles, :dependent => :destroy 
  has_many :repositories, :through => :roles, :source => :resource, :source_type => 'Repository'

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  attr_accessor :login, :updating_password
  # Setup accessible attributes for your model
  attr_accessible :login, :username, :name, :email, :password, :password_confirmation, :remember_me, :encrypted_password, :provider, :uid

  validates_uniqueness_of :username, :case_sensitive => false
  validates_presence_of :username, :format => {:with => /^[\w]+$/ , :message => "username contains illegal characters"}
  validates_presence_of :password, :if => :should_validate_password?
  validates :email, :presence => true, :uniqueness => true, :format => {:with => /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i , :message => "does not look like an e-mail address"} # Regex from devise, see http://rawsyntax.com/blog/rails-3-email-validation/
  validates :name, :presence => true, :format => {:with => /^[\w\s]+$/ , :message => "name contains illegal characters"}
  
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
    query = {:title => title, :resource_id => nil}
    query[:resource_id] = resource.id unless resource.nil?
    query[:resource_type] = resource.class.to_s unless resource.nil?
    roles.find(:first, :conditions => query).destroy
  end
  
  def has_role?(title, resource = nil)
    query = {:title => title, :resource_id => nil}
    query[:resource_id] = resource.id unless resource.nil?
    query[:resource_type] = resource.class.to_s unless resource.nil?
    roles.find(:first, :conditions => query) == nil ? false : true
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
  
  def all_repositories
    repositories + owned_repositories
  end
  
  def owned_repositories
    Repository.where(:owner_id => self)
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
