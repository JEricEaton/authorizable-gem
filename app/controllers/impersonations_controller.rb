class ImpersonationsController < ApplicationController
  append_before_filter :require_admin_role
  
  def create
    session[:impersonated_user_id] = params[:user_id].to_i
    
    if respond_to?(:after_impersonation_start)
      send(:after_impersonation_start)
    else
      redirect_to root_path
    end
  end
  
  def stop
    raise NonAdminNotAllowedToImpersonateError unless current_user.admin?
    
    session.delete :impersonated_user_id
    
    if respond_to?(:after_impersonation_stop)
      send(:after_impersonation_stop)
    else
      redirect_to root_path
    end
  end
  
  private
    def require_admin_role
      raise Authorizable::NonAdminNotAllowedToImpersonateError unless current_user.admin?
    end
end