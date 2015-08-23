require 'spec_helper'

describe Role do
  
  it "belongs to a user" do
    role = Role.new
    role.title = "watcher"
    role.resource = FactoryGirl.build_stubbed(:repository)
    expect(role.save).to be_falsey
    user = FactoryGirl.build_stubbed(:user)
    role.user = user
    expect(role.save).to be_truthy
  end
  
  it "is not valid unless the role title is predefined" do
    role = Role.new
    role.title = "some_role"
    user = FactoryGirl.build_stubbed(:user)
    role.user = user
    role.save
    expect(role.errors.messages[:title]).to include "is not included in the list"
  end
  
  it "does not allow additional roles on a resource for which one is owner" do
    repo = FactoryGirl.build_stubbed(:repository)
    user = repo.owner
    role = Role.new
    role.title = "watcher"
    role.resource = repo
    role.resource_type = Repository
    role.user = user
    role.save
    expect(role.errors.messages[:base]).to include "Cannot have a role on a repository that is owned by the user."
  end

end