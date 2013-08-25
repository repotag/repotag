FactoryGirl.define do
  
  factory :user do
    sequence(:username) {|n| "user#{n}"}
    name "Test User"
    sequence(:email) {|n| "#{username}#{n}@test.org"}
    password 'koekje123'
    admin false
    factory :user_owns_repo do
      after(:create) do |user|
        user.roles [FactoryGirl.create(:owner_role, :user => user)]
      end
    end
    factory :admin_user do
      after(:create) do
        user.admin true
      end
    end
  end
  
  # Admin user
  factory :admin_owns_repo, :parent => :admin_user do
    after(:create) do |user|
      user.roles [FactoryGirl.create(:owner_role, :user => user)]
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
    factory :owner_role do
      title "owner"
    end
  end
  
end
