class Mailer < ActionMailer::Base
  default :from => "no-reply@repotag.org"
  default :to => "patrick.pepels@gmail.com"

  def new_message(message)
    @message = message
   mail(:subject => "[repotag.org] #{@message.subject}")
  end

end
