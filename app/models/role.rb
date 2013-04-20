class Role < ActiveRecord::Base

  attr_accessible :title
  
  belongs_to :user
  belongs_to :repository
  
  validates :user_id, :presence => true
  validates :repository_id, :presence => true
  
end
