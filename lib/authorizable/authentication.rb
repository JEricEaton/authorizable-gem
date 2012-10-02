# Usage: Include Authorizable::Authentication in your ApplicationController
module Authorizable
  module Authentication
    extend ActiveSupport::Concern
    
    ROOT_PATH = '/'
    AUTH_COOKIE = :auth_token
  
    included do
      if Authorizable.configuration.nil?
        throw "Authorizable has not been configured!"
      end
      
      prepend_before_filter :require_authentication
      helper_method :current_user, :admin_route?
      hide_action :current_user, :admin_route?, :render_unauthorized, :after_sign_in
      
      rescue_from Authorizable::UnathorizedAccessError, with: :redirect_to_sign_in
    end
  
    module ClassMethods
      def public_resources
        yield
      end
    
      def allow(contoller_with_actions)
        Authorizable.configuration.add_public_resource contoller_with_actions
      end
    end
  
    def current_user
      @current_user ||= find_active_user_according_to_auth_cookie

      # Impersonation
      if @current_user && @current_user.try(:admin?) && session[:impersonated_user_id]
        begin
          @current_user = Authorizable.configuration.user_model.find session[:impersonated_user_id]
        rescue ActiveRecord::RecordNotFound
          session.delete :impersonated_user_id
        end
      end
      
      @current_user
    end
    
    def find_active_user_according_to_auth_cookie
      return nil if cookies[AUTH_COOKIE].blank?

      scope = Authorizable.configuration.user_model
      if scope.respond_to?(:active)
        scope = scope.active
      end
      scope.where(auth_token: cookies[AUTH_COOKIE]).first
    end
    
    def reload_current_user
      @current_user = find_active_user_according_to_auth_cookie
    end
    
    def redirect_to_after_sign_in
      ROOT_PATH
    end

    def require_authentication
      unathorized! unless authorized?
    end

    def unathorized!
      raise UnathorizedAccessError
    end

    def authorized?
      if current_user.respond_to?(:admin?) && current_user.admin? # Admin can access everything
        true 
      elsif current_user.nil? && guest_can?
        true
      elsif current_user && !admin_route?
        true
      else
        false
      end
    end

    # Can unautrorized user access the current controller#action?
    # :root is allowed by default
    def guest_can?
      public_resources = Authorizable.configuration.public_resources
      if request.path == ROOT_PATH
        true
      elsif public_resources[params[:controller]] && public_resources[params[:controller]] == :all
        true
      elsif public_resources[params[:controller]] && public_resources[params[:controller]].include?(params[:action])
        true
      else
        false
      end
    end

    def admin_route?
      params[:controller].index('admin/') == 0
    end
    
    def render_unauthorized
      render Authorizable.configuration.unauthorized_template, layout: false, status: :unauthorized, formats: 'html'
    end

    def redirect_to_sign_in
      redirect_to sign_in_path(r: request.path)
    end
  end
end
