# encoding: UTF-8
require 'test_helper'

module Authorizable
  class ExampleController < ActionController::Base
    include Authorizable::Authentication
  end
  
  class AuthenticationTest < ActiveSupport::TestCase
    test "module" do
      assert Authentication.is_a?(Module)
    end
    
    def setup
      @controller = ExampleController.new
    end
    
    test "controller responds to current_user" do
      assert @controller.respond_to?(:current_user)
    end
  end
end
