class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
 
  has_many :roles, :dependent => :destroy 
  has_many :repositories, :through => :roles
  
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :encrypted_password, :provider, :uid

  validates :email, :presence => true, :uniqueness => true
  validates :password, :presence => true
  validates :name, :presence => true 

end
