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
      hide_action :current_user, :admin_route?, :redirect_to_sign_in, :after_sign_in
      
      rescue_from Authorizable::UnathorizedAccessError, with: :redirect_to_sign_in

      protect_namespaces :admin
    end
  
    module ClassMethods
      def group_access role
        ResourceAccess.instance.role = role
        yield ResourceAccess.instance
      end

      def protect_namespaces *namespaces
        namespaces.each { |n| ResourceAccess.instance.protect_namespace n }
      end

      # deprecated
      def public_resources
        puts "Authorizable public_resources controller method is deprecated. Use the new 'group_access'!"
        yield
      end
    
      # deprecated
      def allow(contoller_with_actions)
        puts "Authorizable allow controller method is deprecated. Use the new 'group_access'!"
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
    
    MIN_AUTH_TOKEN_LENGHT = 10
    def find_active_user_according_to_auth_cookie
      return nil if cookies[AUTH_COOKIE].blank?
      
      auth_token = cookies[AUTH_COOKIE].to_s
      return nil if auth_token.size < MIN_AUTH_TOKEN_LENGHT

      scope = Authorizable.configuration.user_model
      if scope.respond_to?(:active)
        scope = scope.active
      end
      
      scope.where(auth_token: auth_token).first
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
      if current_user && ResourceAccess.protected_namespace?(routing_namespace)
        unless current_user.respond_to? :access_roles
          throw "User instance needs to respond to 'access_roles'. This is where you can explicitly define user's access to resources based on namespaces."
        end
        ResourceAccess.allowed? current_user.access_roles, params[:controller], params[:action]
      elsif current_user
        # The basic rule for all applications using Authorizable:
        # ** Logged in user has access to all resources unless the namespace is protected - then the access has to be explicitly allowed to a role using 'group_access' controller method **
        true
      else
        ResourceAccess.allowed? :public, params[:controller], params[:action]
      end
    end

    def admin_route?
      params[:controller].index('admin/') == 0
    end

    def routing_namespace
      parts = params[:controller].split '/'
      if parts.size > 1
        parts.first
      else
        nil
      end      
    end    

    def redirect_to_sign_in
      r = request.url.split(request.host).second
      redirect_to sign_in_path(r: r)
    end
  end
end
