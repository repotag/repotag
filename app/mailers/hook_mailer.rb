class HookMailer < ActionMailer::Base
  default :from => "no-reply@repotag.org"
  default :to => "repotag@repotag.org"

  def commit_hook(user)
    mail(:to => user.email, :subject => "[repotag.org] Hook")
  end
  
end
