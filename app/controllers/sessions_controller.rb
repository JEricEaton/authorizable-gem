class SessionsController < ApplicationController
  unloadable
  
  include Authorizable::ImpersonationsHelper
  
  skip_before_filter :require_authentication, :only => [:new, :create]
  
  # Sign in screen
  def new; end

  def create
    # Enforce strong_attributes
    unless params.respond_to? :require
      throw "Authorizable requires the usage of strong_parameters gem!"
    end

    # If the IP is banned, do not allow to sign in
    if Authorizable::Abuse.ip_banned?(request.remote_ip)
      render_banned and return
    end
    
    reset_session # session fixation attack mitigation
    @user = Authorizable.configuration.user_model.find_by_email(session_params[:email])
    if @user.try(:authenticate, session_params[:password])
      # TODO: test inactive & halted user
      if @user.respond_to?(:inactive?) && @user.inactive?
        flash.now.alert = Authorizable.configuration.inactive_account_sign_in_message
        render "new" and return
      elsif @user.respond_to?(:halted?) && @user.halted?
        flash.now.alert = Authorizable.configuration.halted_account_sign_in_message
        render "new" and return
      end
      @user.regenerate_auth_token
      
      # TODO: test remember me
      if session_params[:remember_me] == '1'
        cookies.permanent[:auth_token] = @user.auth_token
      else  
        cookies[:auth_token] = @user.auth_token
      end
      
      after_sign_in if respond_to?(:after_sign_in)

      if return_to_path
        redirect_to return_to_path
      else
        # TODO: test after_sign_in callback
        redirect_to redirect_to_after_sign_in
      end
    else
      abuse = Authorizable::Abuse.failed_attempt! request.remote_ip
      if abuse.banned?
        render_banned and return
      elsif abuse.show_ban_warning?
        flash.now.alert = Authorizable.configuration.failed_attempts_warning.sub('%remaining_attempts_count%', abuse.remaining_attempts_count.to_s)
      else
        flash.now.alert = Authorizable.configuration.invalid_sign_in_message
      end
      
      render "new"
    end
  end

  def destroy
    if impersonating?
      stop_impersonating and return
    end
    
    cookies.delete(:auth_token)
    current_user.update_attribute :auth_token, nil
    redirect_to sign_in_path, :notice => "You've signed out."
  end
  
  private
    def session_params
      params.require(:session).permit(:email, :password, :remember_me)
    end

    def return_to_path
      url = ""
      if params[:r]
        url = params[:r].to_s
      elsif params[:session] && params[:session][:r]
        url = params[:session][:r].to_s
      end
      if url && url[0] == '/' # this only allows paths relative to the root
        url
      end
    end
    helper_method :return_to_path
    
    def render_banned
      render 'banned', layout: false, status: :forbidden, formats: 'html'
    end
end
