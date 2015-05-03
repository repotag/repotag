class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
      if user.admin?
       can :manage, :all
      else
       can :read, Repository do |repo|
         repo.public? or (repo.watchers + repo.contributors << repo.owner).include?(user)
       end
       can :manage, Repository do |repo|
         repo.owner == user
       end
       can :edit, Repository do |repo|
         repo.owner == user || repo.contributors.include?(user)
       end
      end
  end

end
