class PasswordResetsController < ApplicationController
  skip_before_action :require_authentication
  before_action :set_user, only: %i[update edit]

  def new; end

  def update
    if @user.update(user_params)
      redirect_to sign_in_path, notice: 'Password has been reset. You can sign in using your new password.'
    else
      render :edit
    end
  end

  def create
    email = params[:email].to_s.chomp.strip
    raise ActiveRecord::RecordNotFound if email.blank? || email.size < 3

    user = User.find_by(email: email)
    if user
      user.update(password_reset_token: user.password_reset_token)
      PasswordResetsMailer.reset(user).deliver_now
      redirect_to new_password_reset_path,
                  notice: 'Email sent with password reset instructions. Please check your email inbox.'
    else
      redirect_to new_password_reset_path, alert: 'Email address not found, please try again.'
    end
  end

  def edit; end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def set_user
    token = params[:id].to_s.chomp.strip
    @user = User.find_by_password_reset_token!(token)
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to new_password_reset_path, alert: 'Invalid Reset token, please try again!'
    return
  end
end
