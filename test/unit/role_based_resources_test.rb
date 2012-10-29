# encoding: UTF-8
require 'test_helper'

module Authorizable
  class RoleBasedResourcesTest < ActiveSupport::TestCase
    test "usage" do
      assert defined?(RoleBasedResources)

      resources = RoleBasedResources.new
      resources.allow :public, 'products'
      resources.allow :public, 'users' => %w(index) 
      resources.allow :product_manager, 'admin/products' => %w(index show)

      assert resources.can_access?(:public, 'products')
      assert resources.can_access?(:public, 'products', 'index')
      refute resources.can_access?(:public, 'users')
      assert resources.can_access?(:public, 'users', 'index')
      refute resources.can_access?(:public, 'users', 'show')
      refute resources.can_access?(:product_manager, 'admin/products')
      assert resources.can_access?(:product_manager, 'admin/products', 'index')
      assert resources.can_access?(:admin, 'products')
      assert resources.can_access?(:admin, 'admin/products')
      assert resources.can_access?(:admin, 'admin/products', 'show')
    end
  end
end