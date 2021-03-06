require 'rjgit'

class Repository < ActiveRecord::Base
  extend FriendlyId
  include SettingConfigurable

  has_many :roles, :as => :resource, :dependent => :destroy
  has_many :users, :through => :roles, :as => :resource
  has_one :setting
  belongs_to :owner, :class_name => 'User'

  friendly_id :name, :use => :scoped, :scope => :owner

  validates :name, :presence => true, :uniqueness => {:scope => :owner, :case_sensitive => false}, :format => {:with => /\A[\w]+\z/ , :message => "contains illegal characters"}
  validates_presence_of :owner

  def filesystem_path
    ::File.join(ApplicationController.helpers.general_setting(:repo_root), filesystem_name)
  end

  def filesystem_name
    "#{self.id}.git"
  end

  def clone_url
    general_settings = Setting.get(:general_settings)
    uri_class = general_settings[:ssl_enabled] ? URI::HTTPS : URI::HTTP
    uri_class.build(:host => general_settings[:server_domain], :port => general_settings[:server_port].to_i, :path => "/git/#{owner.username}/#{name}")
  end
  
  def wiki_name
    "#{self.id}-wiki.git"
  end

  def wiki_path
    ::File.join(ApplicationController.helpers.general_setting(:wiki_root), wiki_name)
  end

  def wiki
    create = !::File.exists?(self.wiki_path)
    RJGit::Repo.new(self.wiki_path, :create => create, :is_bare => true)
  end

  def wiki_enabled?
    return false if ApplicationController.helpers.general_setting(:enable_wikis) == '0'
    self.settings[:enable_wiki]
  end
  
  def has_wiki?
    ::File.exist?(self.wiki_path)
  end
  
  
  def archive(archive_dir = Setting.get(:general_settings)[:archive_root])
    archive_path = archive_repo(archive_dir)
    has_wiki = self.has_wiki?
    wiki_archive_path = has_wiki ? archive_wiki(archive_dir) : nil
    if archive_path
      self.archived = true 
      self.archived_at = DateTime.current
      self.save
    end
    return archive_path, wiki_archive_path
  end
  
  def unarchive(archive_dir = Setting.get(:general_settings)[:archive_root])
    repo_path = unarchive_repo(archive_dir)
    wiki_path = unarchive_wiki(archive_dir)
    if repo_path
      self.archived = false
      self.archived_at = nil
      self.save
    end
    return repo_path, wiki_path
  end
  
  def archive_repo(archive_dir)
    Tarchiver::Archiver.archive(self.filesystem_path, archive_dir, {verbose: false, raise_errors: true, delete_input_on_success: true})
  end
  
  def unarchive_repo(archive_dir = Setting.get(:general_settings)[:archive_root] )
    archive = ::File.join(archive_dir, "#{self.filesystem_name}.tgz")
    Tarchiver::Archiver.unarchive(archive, Setting.get(:general_settings)[:repo_root], {verbose: false, raise_errors: true, delete_input_on_success: true}) #&&
  end
  
  def archive_wiki(archive_dir)
    Tarchiver::Archiver.archive(self.wiki_path, archive_dir, {verbose: true, raise_errors: true, delete_input_on_success: true})
  end
  
  def unarchive_wiki(archive_dir)
    wiki_archive = ::File.join(archive_dir, "#{self.wiki_name}.tgz")
    Tarchiver::Archiver.unarchive(wiki_archive, Setting.get(:general_settings)[:wiki_root], {delete_input_on_success: true})
  end
  
  def repository
    RJGit::Repo.new(self.filesystem_path)
  end

  def to_disk
    return self.repository if ::File.exists?(self.filesystem_path)
    return RJGit::Repo.new(self.filesystem_path, :create => true, :is_bare => true)
  end

  def all_users
    collaborating_users + [self.owner]
  end

  def collaborating_users(title=nil)
    conditions = {:resource_type => "Repository", :resource_id => id}
    conditions[:title] = title unless title.nil?
    User.where(:id => Role.where(conditions).select(:user_id)).to_a
  end
  
  def contributing_users
    collaborating_users(:contributor)
  end

  def watching_users
    collaborating_users(:watcher)
  end
  
  def initialize_readme(wiki=false)
    repo = wiki ? self.wiki : self.to_disk
    text = wiki ? "# Welcome to the #{self.name} wiki!\nSome gollum instructions" : "# README for #{self.name}"
    tree = RJGit::Tree.new_from_hashmap(repo, { "README.md" => text})
    commit = RJGit::Commit.new_with_tree(repo, tree, "Initialize readme (from Repotag)", RJGit::Actor.new(self.owner.name, self.owner.email))
    repo.update_ref(commit)
  end
  
  def populate_with_test_data
    repo = self.to_disk
    tree = RJGit::Tree.new_from_hashmap(repo, { "README.md" => "# This is a test repo with one directory and two files.", "scriptdir" => { "multiline.rb" => "class PowerShell\n\tdef do_stuff\n\t\tdo_stuff!\n\tend\nend", "reverse.rb" => "ruby -e 'File.open('foo').each_line { |l| puts l.chop.reverse }'" }} )
    commit = RJGit::Commit.new_with_tree(repo, tree, "Test commit message", RJGit::Actor.new("test","test@repotag.org"))
    repo.update_ref(commit)
  end

  def should_generate_new_friendly_id?
    slug.blank? || name_changed?
  end

  # Returns an array of users for a specific repository with an optionally specified role.
  def self.users(repository, role_title = nil)
    query = {:repositories => {:id => repository}, :roles => {:resource_type => 'Repository'}}
    query[:roles][:title] = role_title unless role_title.nil?
    User.joins(:repositories, :roles).where(query).to_a
  end

  def self.from_request_path(path)
    return nil unless /^\/([\w]+)\/([\w]+)/ =~ path
    user = Regexp.last_match[1]
    repo = Regexp.last_match[2]
    begin
      Repository.where(:owner_id => User.friendly.find(user)).friendly.find(repo)
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end

  def self.default_settings
    {:default_branch => 'refs/heads/master',
     :enable_wiki => ApplicationController.helpers.general_setting(:enable_wikis), 
     :enable_issuetracker => ApplicationController.helpers.general_setting(:enable_issuetracker),
     :wiki => {}
    }
  end

  def to_json
    ActiveSupport::JSON.encode(self)
  end

end