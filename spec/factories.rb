FactoryGirl.define do
  
  factory :user do
    sequence(:username) {|n| "user#{n}"}
    name "Test User"
    sequence(:email) {|n| "#{username}#{n}@repotag.org"}
    password 'koekje123'
  end
    
  factory :repository do
    sequence(:name) {|n| "repo#{n}"}
    association :owner, :factory => :user
    
    factory :repository_with_wiki do
        after(:create) do |repo|
          $stderr.puts "building wiki... ID: #{repo.id}"
          repo.wiki
        end
      end
  end
  
  factory :role do
    user
    factory :admin_role do
      title "admin"
      resource nil
    end
    factory :watcher_role do
      association :resource, :factory => :repository
      title "watcher"
    end
    factory :contributor_role do
      association :resource, :factory => :repository
      title "contributor"
    end
  end
  
end
