# encoding: UTF-8
require 'test_helper'

module Authorizable
  # Create a Rails Controller in place, to minimize test dependencies
  class ExampleController < ActionController::Base
    include Authorizable::Authentication
    
    # Override cookies method to get rid of "NoMethodError: undefined method `cookie_jar' for nil:NilClass"
    def cookies
      {}
    end
  end
  
  class AuthenticationTest < ActiveSupport::TestCase
    test "module" do
      assert Authentication.is_a?(Module)
    end
    
    def setup
      @subject = ExampleController.new
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
  end
end
