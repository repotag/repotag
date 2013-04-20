# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)

user = User.create!(:name => "Test User", :email => "test@repotag.org", :password => "koekje123")
repo = Repository.create!(:name => "Test Repo")
role = Role.create(:title => :owner)
role.repository_id = repo.id
role.user_id = user.id
role.save