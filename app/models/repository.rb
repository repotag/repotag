require 'rjgit'

class Repository < ActiveRecord::Base

  has_many :roles, :as => :resource, :dependent => :destroy
  has_many :users, :through => :roles, :as => :resource
  has_one :setting
  belongs_to :owner, :class_name => 'User'

  attr_accessible :name, :public

  validates :name, :presence => true, :format => {:with => /\A[\w]+\z/ , :message => "contains illegal characters"}
  validates_presence_of :owner

  def filesystem_path
    File.join(Setting.get(:general_settings)[:repo_root], filesystem_name)
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

  def self.pluralize(word)
      ActiveSupport::Inflector.pluralize(word)
  end

  def all_users
    Repository.users(self) + [self.owner]
  end

  Repotag::Application.config.role_titles.each do |role_title|
    define_method(self.pluralize(role_title.to_s)) do
      Repository.users(self, role_title)
    end
  end

  # Returns an array of users for a specific repository with an optionally specified role.
  def self.users(repository, role_title = nil)
    query = {:repositories => {:id => repository}, :roles => {:resource_type => 'Repository'}}
    query[:roles][:title] = role_title unless role_title.nil?
    User.joins(:repositories, :roles).where(query).to_a
  end

  def self.from_request_path(path)
    return nil unless /^\/[\w]+\/[\w]+$/ =~ path
    elements = path.split(File::SEPARATOR)
    user = elements[1]
    repo = elements[2]
    user = User.find(:first, :conditions => {:username => user})
    user ? user.owned_repositories.find {|r| r.name == repo} : nil
  end

  def to_json
    ActiveSupport::JSON.encode(self)
  end

end