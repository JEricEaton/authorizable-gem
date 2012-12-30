class ImpersonationsController < ApplicationController
  unloadable
  
  include Authorizable::ImpersonationsHelper
  
  def create
    raise Authorizable::NonAdminNotAllowedToImpersonateError unless current_user.admin?
    
    session[:impersonated_user_id] = params[:user_id].to_i
    
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