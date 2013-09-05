# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)

user = User.create!(:username => "testuser", :name => "Test User", :email => "test@repotag.org", :password => "koekje123")
repo = Repository.create!(:name => "Test Repo")
role = Role.create(:title => :owner)
role.repository_id = repo.id
role.user_id = user.id
role.save

user = User.create(:username => "admin_user", :name => "Admin User", :email => "repotag@repotag.org", :password => "koekje123")
user.admin = true
user.save
repo = Repository.create!(:name => "Super Secret Repo")
role = Role.create(:title => :owner)
role.repository_id = repo.id
role.user_id = user.id
role.save

smtp_settings = Setting.create(:name => :smtp_settings, :settings => {:address => 'localhost', :port => 25})
smtp_settings.save