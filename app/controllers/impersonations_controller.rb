class ImpersonationsController < ApplicationController
  unloadable
  
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
    impersonated_user = @current_user
    session.delete :impersonated_user_id
    reload_current_user
    
    if respond_to?(:after_impersonation_stop)
      send(:after_impersonation_stop, impersonated_user)
    else
      redirect_to root_path
    end
  end
end