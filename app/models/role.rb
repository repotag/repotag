class Role < ActiveRecord::Base

  attr_accessible :title
  
  belongs_to :user
  # Following http://edapx.com/2012/04/18/authorization-and-user-management-in-rails/
  # it would be better to use
  # has_and_belongs_to_many :users
  belongs_to :repository
  
  validates :user_id, :presence => true
  validates :repository_id, :presence => true
  
end
