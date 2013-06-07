class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
      if user.admin?
       can :manage, :all
      else
       can :read, Repository do |repo|
         repo.public? or (repo.owners + repo.watchers + repo.contributors).include?(user)
       end
       can :manage, Repository do |repo|
         repo.owners.include?(user)
       end
       can :edit, Repository do |repo|
         (repo.owners + repo.contributors).include?(user)
       end
      end
  end
  
end
