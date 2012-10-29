module Authorizable
  require 'singleton'
  
  class ResourceAccess
    include Singleton
    attr_accessor :role

    def initialize
      @role_based_resources = RoleBasedResources.new
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
  end
end