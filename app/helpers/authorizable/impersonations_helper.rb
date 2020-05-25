module Authorizable
  module ImpersonationsHelper
    def stop_impersonating
      impersonated_user = current_user
      session.delete :impersonated_user_id

      if respond_to?(:after_impersonation_stop)
        send(:after_impersonation_stop, impersonated_user)
      else
        redirect_to :root
      end
      reload_current_user
    end

    def impersonating?
      session[:impersonated_user_id].present?
    end
  end
end
