module Authorizable
  require 'singleton'
  
  class ResourceAccess
    include Singleton
    attr_accessor :role

    def initialize
      @role_based_resources = RoleBasedResources.new
      @protected_namespaces = []
    end

    def allow controller_with_actions
      @role_based_resources.allow role, controller_with_actions
    end

    def can_access? role, controller, action = nil
      @role_based_resources.can_access? role, controller, action
    end

    def self.allowed? roles, controller, action = nil
      roles = roles.is_a?(Array) ? roles : [roles]
      roles.each do |role|
        return true if instance.can_access? role, controller, action
      end
      false
    end

    def protect_namespace namespace
      @protected_namespaces << namespace.to_sym unless protected_namespace? namespace
    end

    def protected_namespace? namespace
      @protected_namespaces.include? namespace.to_sym
    end

    def self.protected_namespace? namespace
      instance.protected_namespace? namespace
    end
  end
end