require 'rjgit'

class Repository < ActiveRecord::Base
  
  has_many :roles, :dependent => :destroy
  has_many :users, :through => :roles
  
  attr_accessible :name, :public
  
  validates :name, :presence => true, :format => {:with => /^[\w]+$/ , :message => "name contains illegal characters"}
  validate :validates_unique_name_for_owner
  
  after_destroy :destroy_owner_role
      
  def filesystem_path
    File.join(Repotag::Application.config.datadir, filesystem_name)
  end
  
  def filesystem_name
    "#{self.id}.git"
  end
  
  def repository
    RJGit::Repo.new(self.filesystem_path)
  end
  
  def to_disk
    return self.repository if File.exists?(self.filesystem_path)
    return RJGit::Repo.new(self.filesystem_path, :create => true)
  end
  
  def owner
    self.owners.first
  end
  
  def owner_role
    Role.find(:first, :conditions => {:repository_id => self, :title => "owner"})
  end
  
  def self.pluralize(word)
      ActiveSupport::Inflector.pluralize(word)
  end
    
  Repotag::Application.config.role_titles.each do |role_title|
    define_method(self.pluralize(role_title.to_s)) do
      Repository.users(self, role_title)
    end
  end
    
  # Returns an array of users for a specific repository with a specified role.
  def self.users(repository, role_title) 
    User.joins(:repositories, :roles).where(:roles => {:title => role_title}, 
                                            :repositories => {:id => repository}).to_a
  end
  
  def self.from_request_path(path)
    return nil unless /^\/[\w]+\/[\w]+$/ =~ path
    elements = path.split(File::SEPARATOR)
    user = elements[1]
    repo = elements[2]
    user = User.find(:first, :conditions => {:username => user})
    user ? user.repositories.find {|r| r.name == repo && r.owner == user} : nil
  end
  
  def to_json
    ActiveSupport::JSON.encode(self)
  end
    
  private
  
  def destroy_owner_role
    ownr = owner_role
    ownr.destroy unless ownr.nil?
  end
  
  def validates_unique_name_for_owner
    errors.add(:base, "Owner already has a repository by this name.") unless owner.nil? || owner.repositories.find {|r| r.id != id && r.name == name && r.owner == owner} == nil
  end

end