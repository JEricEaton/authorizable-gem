# encoding: UTF-8
require 'test_helper'

module Authorizable
  class Tester < ActionController::Base
    include Authorizable::User
  end
  
  class UserTest < ActiveSupport::TestCase
    test "module" do
      assert Authorizable::User.is_a?(Module)
    end
    
    def setup
      @subject = Tester.new
    end

  end
end
