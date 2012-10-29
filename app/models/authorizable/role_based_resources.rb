module Authorizable
  class RoleBasedResources
    def initialize
      @map = {}
    end

    def allow role, controller_with_actions
      unless @map.has_key? role
        @map[role] = []
      end
      @map[role] << controller_with_actions
    end

    def can_access? role, controller, action = nil
      return true if role == :admin # admin can access everything
      return false unless @map.has_key? role

      resources = @map[role]
      matches = 0
      if action.nil?
        matches = resources.select{ |item| item.to_s == controller.to_s }.count
      else
        matches = resources.select do |item| 
          if item == controller
            true
          elsif item.respond_to?(:keys)
            if item.keys == [controller]
              allowed_actions = item.values.first
              allowed_actions.include? action
            end
          end
        end.count
      end
      matches > 0
    end
  end
end