# encoding: UTF-8
require 'test_helper'

module Authorizable
  # Create a Rails Controller in place, to minimize test dependencies
  class ExampleApplicationController < ActionController::Base
    # Override these methods to get rid of "NoMethodError: undefined method `cookie_jar' for nil:NilClass"
    attr_accessor :cookies, :params

    include Authorizable::Authentication

    group_access :public do |a|
      a.allow 'pages' => %w(home)
    end

    group_access :product_manager do |a|
      a.allow 'admin/products' => %w(index show)
    end
  end
  
  class AuthenticationTest < ActiveSupport::TestCase
    test "module" do
      assert Authentication.is_a?(Module)
    end
    
    def setup
      @subject = ExampleApplicationController.new
      @subject.cookies = @subject.params = {}
    end
    
    test "instance responds to current_user" do
      assert @subject.respond_to?(:current_user)
    end
    
    test "controller class responds to public_resources" do
      assert ExampleApplicationController.respond_to?(:public_resources)
    end
    
    test "by default current_user returns nil" do
      assert_nil @subject.current_user
    end
    
    test "admin_route?" do
      @subject.params = { controller: 'admin/users' }
      assert @subject.admin_route?
    end
    
    test "unless the admin word is suffixed with slash it's not considered an admin router" do
      @subject.params = { controller: 'admin_users' }
      assert !@subject.admin_route?
    end

    test "role_based_resources class attribute is populated when the first call to allow happens" do
      assert ResourceAccess.allowed?(:public, 'pages', 'home')
      assert ResourceAccess.allowed?(:product_manager, 'admin/products', 'index')
      assert ResourceAccess.allowed?(:product_manager, 'admin/products', 'show')
      refute ResourceAccess.allowed?(:product_manager, 'admin/products')
      refute ResourceAccess.allowed?(:product_manager, 'something_non_existent')
    end

    test "admin namespace is protected by default" do
      assert ResourceAccess.protected_namespace?(:admin)
      assert ResourceAccess.protected_namespace?('admin')
    end
  end
end
