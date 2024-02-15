class ImpersonationsController < ApplicationController
  include Authorizable::ImpersonationsHelper

  def create
    user = Authorizable.configuration.user_model.find params[:user_id].to_i

    raise Authorizable::NonAdminNotAllowedToImpersonateError unless current_user.can_sign_in_as?(user)

    session[:impersonated_user_id] = user.id

    if respond_to?(:after_impersonation_start)
      send(:after_impersonation_start)
    else
      redirect_to root_path
    end
  end

  def stop
    stop_impersonating
  end
end
