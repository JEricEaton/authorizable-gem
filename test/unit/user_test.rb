# encoding: UTF-8
require 'test_helper'

module Authorizable
  class UserTest < ActiveSupport::TestCase
    fixtures :users
    
    def setup
      Authorizable.configuration.password_salt = "$2a$10$fREDiaGGPkyyXBNXM/Ae/O"
    end
    
    test "module" do
      assert Authorizable::User.is_a?(Module)
    end
    
    test "can be authenticated using password matching password_digest in database" do
      robert = users(:robert)
      assert robert.authenticate('antonio')
      
      andrea = users(:andrea)
      assert andrea.authenticate('andrea')
    end
    
    test "can NOT be authenticated using password NOT matching password_digest in database" do
      robert = users(:robert)
      assert !robert.authenticate('notthere')
    end
  end
end
