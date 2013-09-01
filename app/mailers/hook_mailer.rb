class HookMailer < ActionMailer::Base
  default :from => "no-reply@repotag.org"
  default :to => "repotag@repotag.org"

  def commit_hook(user)
    mail(:to => user.email, :subject => "[Repotag] Hook")
  end
  
  def activity_report(user, repository)
    @user = user
    @repository = repository
    mail(:to => @user.email, :subject => "[Repotag] Activity report for #{@repository.name}")
  end
  
  def commit_details(user, repository, commit)
    @user = user
    @repository = repository
    @commit = commit
    mail(:to => @user.email, :subject => "[Repotag] Commit details for #{@repository.name}")
  end
   
  
end
