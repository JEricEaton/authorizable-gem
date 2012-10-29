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
    end
  
    module ClassMethods
      def resources_for role
        ResourceAccess.instance.role = role
        yield ResourceAccess.instance
      end

      # deprecated
      def public_resources
        puts "Authorizable public_resources controller method is deprecated. Use the new 'resources_for'!"
        yield
      end
    
      # deprecated
      def allow(contoller_with_actions)
        puts "Authorizable allow controller method is deprecated. Use the new 'resources_for'!"
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
      # todo: require access_to_route_namespaces only if the namespace requires it - admin should require it by default 
      if current_user && routing_namespace
        unless current_user.respond_to? :access_to_route_namespaces
          throw "User instance needs to respond to 'access_to_route_namespaces'. This is where you can explicitly define user's access to resources based on namespaces."
        end
        ResourceAccess.allowed? current_user.access_to_route_namespaces, params[:controller], params[:action]
      elsif current_user
        # The basic rule for all applications using Authorizable:
        # ** Logged in user has access to all resources without a namespace **
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
