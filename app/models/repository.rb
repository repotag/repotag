class Repository < ActiveRecord::Base
  
  has_many :roles, :dependent => :destroy
  has_many :users, :through => :roles
  
  attr_accessible :name
  
  validates :name, :presence => true
  
  def self.path(repository)
    return '/tmp/test'
  end
  
  def self.pluralize(word)
      ActiveSupport::Inflector.pluralize(word)
  end
    
  Repotag::Application.config.role_titles.each do |role_title|
    define_method(self.pluralize(role_title.to_s)) do
      Repository.users(self.name, role_title)
    end
    
    # Returns an array of users for a specific repository with a specified role.
    def self.users(repository_name, role_title) 
      User.joins(:repositories, :roles).where(:roles => {:title => role_title}, 
                                              :repositories => {:name => repository_name}).to_a
    end
    
    def to_json
      ActiveSupport::JSON.encode(self)
    end
    
  end
  
end
