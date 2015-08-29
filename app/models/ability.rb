class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
      if user.admin?
       can :manage, :all
      else

        # Repositories
        can :read, Repository do |repo|
          repo.public? or (repo.watching_users + repo.contributing_users << repo.owner).include?(user)
        end
        can :manage, Repository do |repo|
          repo.owner == user
        end
        can [:edit, :update], Repository do |repo|
          repo.owner == user || repo.contributing_users.include?(user)
        end
      
        # Users
        can [:read, :edit, :update], User do |u| 
          user == u
        end

      end # user.admin?
  end

end
