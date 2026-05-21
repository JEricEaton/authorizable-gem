class PasswordResetsMailer < ApplicationMailer
  def reset(user)
    @user = user
    @token = user.password_reset_token
    mail_to_user_with_subject 'Password Reset Instructions'
  end
end
