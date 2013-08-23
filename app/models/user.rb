class User < ActiveRecord::Base
 
  has_many :roles, :dependent => :destroy 
  has_many :repositories, :through => :roles

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  attr_accessor :login, :updating_password
  # Setup accessible attributes for your model
  attr_accessible :login, :username, :name, :email, :password, :password_confirmation, :remember_me, :encrypted_password, :provider, :uid

  validates_uniqueness_of :username, :case_sensitive => false
  validates_presence_of :username
  validates_presence_of :password, :if => :should_validate_password?
  validates :email, :presence => true, :uniqueness => true
  validates :name, :presence => true
  
  def should_validate_password?
    new_record? || updating_password
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
