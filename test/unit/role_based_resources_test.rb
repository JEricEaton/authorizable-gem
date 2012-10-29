# encoding: UTF-8
require 'test_helper'

module Authorizable
  class RoleBasedResourcesTest < ActiveSupport::TestCase
    test "usage" do
      assert defined?(RoleBasedResources)
    end
  end
end