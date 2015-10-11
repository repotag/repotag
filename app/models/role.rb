class Role < ActiveRecord::Base
  belongs_to :user
  belongs_to :resource, :polymorphic => true

  validates :user, :presence => true, :uniqueness => {:scope => [:resource_type, :resource_id]}
  validates_presence_of :resource_type, :unless => Proc.new {self.resource_id.nil?}
  validates_presence_of :resource_id, :unless => Proc.new {self.resource_type.nil?}

  validates_inclusion_of :title, :in => Repotag::Application.config.role_titles.map(&:to_s), :unless => Proc.new {self.resource_id.nil?}
  validates_inclusion_of :title, :in => Repotag::Application.config.global_role_titles.map(&:to_s), :if => Proc.new {self.resource_id.nil?}

  validate :validates_no_roles_for_repo_owner

  def validates_no_roles_for_repo_owner
    if self.resource_type == 'Repository' && self.user
      errors.add(:base, "Cannot have a role on a repository that is owned by the user.") if self.resource.owner.id == self.user.id
    end
  end

end
