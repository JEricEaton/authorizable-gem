class ImpersonationsController < ApplicationController
  before_filter :require_admin_role
  
  def create
    session[:impersonated_user_id] = params[:impersonated_user_id]
    
    if defined?(:after_impersonation_start)
      send(:after_impersonation_start)
    else
      redirect_to root_path
    end
  end
  
  def destroy
    raise NonAdminNotAllowedToImpersonateError unless current_user.admin?
    
    session.delete :impersonated_user_id
    
    if defined?(:after_impersonation_stop)
      send(:after_impersonation_stop)
    else
      redirect_to root_path
    end
  end
  
  private
    def require_admin_role
      raise NonAdminNotAllowedToImpersonateError unless current_user.admin?
    end
end