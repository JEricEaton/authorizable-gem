# encoding: UTF-8
require 'test_helper'

module Authorizable
  # Create a Rails Controller in place, to minimize test dependencies
  class ExampleController < ActionController::Base
    include Authorizable::Authentication
    
    # Override these methods to get rid of "NoMethodError: undefined method `cookie_jar' for nil:NilClass"
    attr_accessor :cookies, :params
  end
  
  class AuthenticationTest < ActiveSupport::TestCase
    test "module" do
      assert Authentication.is_a?(Module)
    end
    
    def setup
      @subject = ExampleController.new
      @subject.cookies = @subject.params = {}
    end
    
    test "instance responds to current_user" do
      assert @subject.respond_to?(:current_user)
    end
    
    test "controller class responds to public_resources" do
      assert ExampleController.respond_to?(:public_resources)
    end
    
    test "by default current_user returns nil" do
      assert_nil @subject.current_user
    end
    
    test "admin_route?" do
      @subject.params = { controller: 'admin/users' }
      assert @subject.admin_route?
    end
    
    test "unless the admin word is suffixed with slash it's not considered an admin router" do
      @subject.params = { controller: 'admin/users' }
      assert @subject.admin_route?
    end
  end
end
