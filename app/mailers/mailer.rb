class Mailer < ActionMailer::Base
  default :from => "no-reply@repotag.org"
  default :to => "repotag@repotag.org"

  def new_message(message)
   @message = message
   mail(:subject => "[Repotag] #{@message}")
  end

  def test_email(user)
    @user = user
    mail(:subject => "[Repotag] Auto-generated test message.", :to => user.email)
  end

end
