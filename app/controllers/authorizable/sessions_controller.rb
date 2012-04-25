module Authorizable
  class SessionsController < ApplicationController
    skip_before_filter :require_authentication, :only => [:new, :create]
    
    # Sign in screen
    def new; end

    def create
      reset_session # session fixation attack mitigation
      user = Authorizable.configuration.user_model.find_by_email(session_params[:email])
      if user.try(:authenticate, session_params[:password])
        user.regenerate_auth_token
        if params[:remember_me]  
          cookies.permanent[:auth_token] = user.auth_token
        else  
          cookies[:auth_token] = user.auth_token
        end
        redirect_to redirect_to_after_sign_in and return
      end
      flash.now.alert = "Invalid email or password."
      render "new"
    end

    def destroy
      cookies.delete(:auth_token)
      current_user.update_attribute :auth_token, ''
      redirect_to sign_in_path, :notice => "You've signed out."
    end
    
    private
      def session_params
        params[:session].slice(:email, :password)
      end
  end
end
