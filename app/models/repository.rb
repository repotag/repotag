require 'rjgit'

class Repository < ActiveRecord::Base
  extend FriendlyId

  has_many :roles, :as => :resource, :dependent => :destroy
  has_many :users, :through => :roles, :as => :resource
  has_one :setting
  belongs_to :owner, :class_name => 'User'

  friendly_id :name, :use => :scoped, :scope => :owner

  attr_accessible :name, :public, :description

  validates :name, :presence => true, :format => {:with => /\A[\w]+\z/ , :message => "contains illegal characters"}
  validates_presence_of :owner

  def filesystem_path
    File.join(ApplicationController.helpers.general_setting(:repo_root), filesystem_name)
  end

  def filesystem_name
    "#{self.id}.git"
  end

  def repository
    RJGit::Repo.new(self.filesystem_path)
  end

  def to_disk
    return self.repository if File.exists?(self.filesystem_path)
    return RJGit::Repo.new(self.filesystem_path, :create => true, :is_bare => true)
  end

  def self.pluralize(word)
      ActiveSupport::Inflector.pluralize(word)
  end

  def all_users
    Repository.users(self) + [self.owner]
  end

  def collaborating_users
    User.where(:id => Role.where(:resource_id => id).select(:user_id)).to_a
  end
  
  def contributing_users
    collaborating_users.select{|collaborator| collaborator.has_role?(:contributor, self) }
  end

  def watching_users
    collaborating_users.select{|collaborator| collaborator.has_role?(:watcher, self) }
  end
  
  def initialize_readme
    tree = RJGit::Tree.new_from_hashmap(self.repository, { "README.md" => "# README for #{self.name}"})
    commit = RJGit::Commit.new_with_tree(self.repository, tree, "Test commit message", RJGit::Actor.new(self.owner.name, self.owner.email))
    self.repository.update_ref(commit)
  end
  
  def populate_with_test_data
    tree = RJGit::Tree.new_from_hashmap(self.repository, { "README.md" => "# This is a test repo with one directory and two files.", "scriptdir" => { "multiline.rb" => "class PowerShell\n\tdef do_stuff\n\t\tdo_stuff!\n\tend\nend", "reverse.rb" => "ruby -e 'File.open('foo').each_line { |l| puts l.chop.reverse }'" }} )
    commit = RJGit::Commit.new_with_tree(self.repository, tree, "Test commit message", RJGit::Actor.new("test","test@repotag.org"))
    self.repository.update_ref(commit)
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
    return nil unless /^\/([\w]+)\/([\w]+)\/wiki\// =~ path
    user = Regexp.last_match[1]
    repo = Regexp.last_match[2]
    Repository.where(:owner_id => User.friendly.find(user)).friendly.find(repo)
  end
  
  def settings
    setting = Setting.where(:repository_id => self).first_or_create
    if setting.name.nil?
      setting.name = self.name.to_sym
      setting.save
    end
    if setting.settings.nil?
      setting.settings = {:default_branch => 'refs/heads/master', :enable_wiki => ApplicationController.helpers.general_setting(:enable_wikis), 
                          :enable_issuetracker => ApplicationController.helpers.general_setting(:enable_issuetracker)}
      setting.save
    end
    setting    
  end

  def to_json
    ActiveSupport::JSON.encode(self)
  end

end