# encoding: utf-8
#
# ===============================
# Warning: ALL ACTIONS ARE PUBLIC
# ===============================
#
class PasswordResetsController < ApplicationController
  def new
  end
  
  def update
    set_user
    @user.force_password_validation = true
    if @user.password_reset_sent_at.blank? || @user.password_reset_sent_at < 2.hours.ago
      redirect_to new_password_reset_path, :alert => "Password reset has expired, you need to try again."  
    elsif @user.update_attributes(user_params)
      redirect_to sign_in_path, :notice => "Password has been reset. You can sign in using your new password."  
    else
      render :edit  
    end
  end
  
  def create
    user = User.find_by_email(params[:email])  
    if user.try(:create_password_reset_token)
      UsersMailer.password_reset(user).deliver
    end
    redirect_to new_password_reset_path, :notice => "Email sent with password reset instructions. Please check your email inbox."
  end
  
  def edit
    set_user
  end
  
  private
    def user_params
      params[:user].slice(:password, :password_confirmation)
    end
    
    def set_user
      throw ActiveRecord::RecordNotFound if params[:id].blank?
      @user = User.find_by_reset_password_token!(params[:id])
    end
end
