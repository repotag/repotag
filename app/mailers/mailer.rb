class Mailer < ActionMailer::Base
  default from: "no-reply@repotag.org"
  default to: "repotag@repotag.org"

  def new_message(message)
   @message = message
   mail(subject: "[Repotag] #{@message}", delivery_method_options: Setting.get(:smtp_settings).settings )
  end

  def test_email(user)
    @user = user
    mail(subject: "[Repotag] Auto-generated test message.", to: user.email, delivery_method_options: Setting.get(:smtp_settings).settings )
  end

end
