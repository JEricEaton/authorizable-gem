# Usage: Include Authorizable::Authentication in your ApplicationController
module Authorizable
  module Authentication
    extend ActiveSupport::Concern
    
    ROOT_PATH = '/'
  
    included do
      if Authorizable.configuration.nil?
        raise "Authorizable has not been configured!"
      end
      
      prepend_before_filter :require_autorization
      helper_method :current_user, :admin_route?
      hide_action :current_user, :admin_route?, :render_unauthorized
      
      rescue_from Authorizable::UnathorizedAccessError, :with => :render_unauthorized
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
      if cookies[:auth_token].present?
        @current_user ||= User.find_by_auth_token(cookies[:auth_token]) 
      end
      @current_user
    end

    def require_autorization
      unathorized! unless authorized?
    end

    def unathorized!
      raise UnathorizedAccessError
    end

    def authorized?
      if current_user.try(:admin?) # Admin can access everything
        true 
      elsif current_user.nil? and guest_can?
        true
      elsif current_user and !admin_route?
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
      render Authorizable.configuration.unauthorized_template, layout: false, status: :unauthorized
    end
  end
end
