class UserMailer < ActionMailer::Base
  default from: "do-not-reply@theballot.org"

  def forgot_password(user, password)
    @user = user
    @password = password
    mail(to: user.email, subject: 'TheBallot.org Lost Password Reset')
  end

end
