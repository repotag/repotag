FactoryGirl.define do
  
  factory :user do
    sequence(:username) {|n| "user#{n}"}
    name "Test User"
    sequence(:email) {|n| "#{username}#{n}@test.org"}
    password 'koekje123'
    factory :user_owns_repo do
      after(:create) do |user|
        user.roles [FactoryGirl.create(:owner_role, :user => user)]
      end
    end
  end
  
  # Admin user
  factory :admin_user do
    sequence(:username) {|n| "user#{n}"}
    name "Admin User"
    sequence(:email) {|n| "#{username}#{n}@test.org"}
    password 'koekje123'
    factory :admin_owns_repo do
      after(:create) do |user|
        user.roles [FactoryGirl.create(:owner_role, :user => user)]
        user.roles [FactoryGirl.create(:admin_role, :user => user)]
      end
    end
  end
  
  factory :repository do
    sequence(:name) {|n| "repo#{n}"}
    factory :repo_with_owner do
      after(:create) do |repo|
        repo.roles [FactoryGirl.create(:owner_role, :repository => repo)]
      end
    end
  end
  
  factory :role do
    user
    repository
    factory :admin_role do
      title "admin"
    end
    factory :owner_role do
      title "owner"
    end
  end
  
end
