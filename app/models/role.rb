class Role < ActiveRecord::Base

  attr_accessible :title
  
  belongs_to :user
  # Following http://edapx.com/2012/04/18/authorization-and-user-management-in-rails/
  # it would be better to use
  # has_and_belongs_to_many :users
  belongs_to :repository
  
  validates_associated :repository
  
  validates_inclusion_of :title, :in => Repotag::Application.config.role_titles.map(&:to_s)
  
  validates :user_id, :presence => true
  
  validates :repository_id, :presence => true
  validates :repository_id, :uniqueness => {:scope => :title}, :if => Proc.new{ self.title == 'owner' }
  validates :repository_id, :uniqueness => {:scope => :user_id}
  
  validate :validates_unique_repo_name_for_owner, :if => Proc.new{ self.title == 'owner' }
  
  before_destroy :repository_has_owner
  
  private
  
  def repository_has_owner
    if self.title == "owner" && !repository.nil? then
      errors.add(:base, "Repository must have at least one owner.")
      return false
    end
  end
  
  def validates_unique_repo_name_for_owner
    errors.add(:base, "Owner already has a repository by this name.") unless user.repositories.find {|r| r.owner == user && r.id != repository.id && r.name == repository.name} == nil
  end
  
end
