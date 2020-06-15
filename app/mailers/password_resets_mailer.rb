class PasswordResetsMailer < ApplicationMailer
  def reset(user)
    @user = user
    mail_to_user_with_subject "Password Reset Instructions"
  end
end
