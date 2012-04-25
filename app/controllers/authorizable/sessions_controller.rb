module Authorizable
  class SessionsController < ApplicationController
    # Sign in screen
    def new; end

    def create
      reset_session # session fixation attack mitigation
      user = Authorizable.configuration.user_model.find_by_email(params[:email])
      if user.try(:authenticate, params[:password])
        user.regenerate_auth_token
        if params[:remember_me]  
          cookies.permanent[:auth_token] = user.auth_token
        else  
          cookies[:auth_token] = user.auth_token
        end
        target_path = wiki_root_path
        redirect_to target_path and return
      end
      flash.now.alert = "Invalid email or password"
      render "new"
    end

    def destroy
      cookies.delete(:auth_token)
      current_user.update_attribute :auth_token, ''
      redirect_to sign_in_path, :notice => "You've signed out."
    end
  end
end
