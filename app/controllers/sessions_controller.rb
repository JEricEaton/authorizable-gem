class SessionsController < ApplicationController
  include Authorizable::ImpersonationsHelper

  skip_before_action :require_authentication, only: %i[new create]

  # Sign in screen
  def new; end

  def create
    # Enforce strong_attributes
    throw 'Authorizable requires the usage of strong_parameters gem!' unless params.respond_to? :require

    # If the IP is banned, do not allow to sign in
    render_banned and return if Authorizable::Abuse.ip_banned?(request.remote_ip)

    @user = Authorizable.configuration.user_model.find_by_email(session_params[:email])
    if @user.try(:authenticate, session_params[:password])
      # TODO: test inactive & halted user
      if @user.respond_to?(:inactive?) && @user.inactive?
        flash[:alert] = Authorizable.configuration.inactive_account_sign_in_message
        render :new, status: :unprocessable_entity
      elsif @user.respond_to?(:halted?) && @user.halted?
        flash[:alert] = Authorizable.configuration.halted_account_sign_in_message
        render :new, status: :unprocessable_entity
      end
      @user.regenerate_auth_token

      # TODO: test remember me
      if session_params[:remember_me] == '1'
        cookies.encrypted.permanent[:auth_token] = {
          value: @user.auth_token,
          secure: Rails.env.production?
        }
      else
        cookies.encrypted[:auth_token] = {
          value: @user.auth_token,
          secure: Rails.env.production?
        }
      end

      after_sign_in if respond_to?(:after_sign_in)

      redirect_to return_to_path || redirect_to_after_sign_in
    else
      abuse = Authorizable::Abuse.failed_attempt! request.remote_ip
      if abuse.banned?
        render_banned and return
      elsif abuse.show_ban_warning?
        flash[:alert] = Authorizable.configuration.failed_attempts_warning.sub('%remaining_attempts_count%',
                                                                               abuse.remaining_attempts_count.to_s)
      else
        flash[:alert] = Authorizable.configuration.invalid_sign_in_message
      end

      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    stop_impersonating and return if impersonating?

    cookies.delete(:auth_token)
    current_user.update_attribute :auth_token, nil
    redirect_to sign_in_path, notice: "You've signed out."
  end

  private

  def session_params
    params.require(:session).permit(:email, :password, :remember_me)
  end

  def return_to_path
    url = ''
    if params[:r]
      url = params[:r].to_s
    elsif params[:session] && params[:session][:r]
      url = params[:session][:r].to_s
    end
    return unless url && url[0] == '/' # this only allows paths relative to the root

    url
  end
  helper_method :return_to_path

  def render_banned
    render 'banned', layout: false, status: :forbidden
  end
end
