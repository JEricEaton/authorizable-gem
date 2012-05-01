class SessionsController < ApplicationController
  unloadable
  
  skip_before_filter :require_authentication, :only => [:new, :create]
  
  # Sign in screen
  def new; end

  def create
    reset_session # session fixation attack mitigation
    @user = Authorizable.configuration.user_model.find_by_email(session_params[:email])
    if @user.try(:authenticate, session_params[:password])
      # :TODO test inactive user
      if @user.respond_to?(:inactive?) && @user.inactive?
        flash.now.alert = "Your account is inactive. Please find the email sent to you on sign up and follow the instructions."
        render "new" and return
      end
      @user.regenerate_auth_token
      if session_params[:remember_me] == '1'
        cookies.permanent[:auth_token] = @user.auth_token
      else  
        cookies[:auth_token] = @user.auth_token
      end
      # :TODO test this callback
      after_sign_in if respond_to?(:after_sign_in)
      redirect_to redirect_to_after_sign_in
    else
      flash.now.alert = "Invalid email or password."
      render "new"
    end
  end

  def destroy
    cookies.delete(:auth_token)
    current_user.update_attribute :auth_token, ''
    redirect_to sign_in_path, :notice => "You've signed out."
  end
  
  private
    def session_params
      params[:session].slice(:email, :password, :remember_me)
    end
end
