module Authorizable
  class RoleBasedResources
    def initialize
      @map = {}
    end

    def allow(role, controller_with_actions)
      @map[role] = [] unless @map.key? role
      @map[role] << controller_with_actions
    end

    def can_access?(role, controller, action = nil)
      return true if role == :admin # admin can access everything
      return false unless @map.key? role

      resources = @map[role]
      matches = if action.nil?
                  resources.select { |item| item.to_s == controller.to_s }.count
                else
                  resources.select do |item|
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
      matches.positive?
    end
  end
end
