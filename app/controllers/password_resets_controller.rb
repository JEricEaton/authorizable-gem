# encoding: utf-8
class PasswordResetsController < ApplicationController
  skip_before_action :require_authentication

  def new
  end

  def update
    set_user
    @user.force_password_validation = true
    if @user.password_reset_sent_at.blank? || @user.password_reset_expired?
      redirect_to new_password_reset_path, alert: "Password reset has expired, you need to try again."
    elsif @user.update_attributes(user_params)
      redirect_to sign_in_path, notice: "Password has been reset. You can sign in using your new password."
    else
      render :edit
    end
  end

  def create
    email = params[:email].to_s.chomp.strip
    raise ActiveRecord::RecordNotFound if email.blank? || email.size < 3
    user = User.where(email: email).first
    if user.try(:create_password_reset_token)
      PasswordResetsMailer.reset(user).deliver_now
    end
    redirect_to new_password_reset_path, notice: "Email sent with password reset instructions. Please check your email inbox."
  end

  def edit
    set_user
  end

  private
  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def set_user
    # Do not allow to fuck around with anything else than at least a 6 characters long string
    token = params[:id].to_s.chomp.strip
    raise ActiveRecord::RecordNotFound if token.blank? || token.size < 6
    @user = User.where(Authorizable.configuration.password_reset_token_column_name => token).first
    raise ActiveRecord::RecordNotFound unless @user
  end
end
