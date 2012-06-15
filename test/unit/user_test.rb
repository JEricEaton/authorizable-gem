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
    
    test "password_reset_expired?" do
      user = users(:robert)
      user.password_reset_sent_at = Time.mktime(2011, 1, 2, 10, 1)
      
      Timecop.travel Time.mktime(2011, 1, 2, 12, 0) do
        assert !user.password_reset_expired?
      end
      
      Timecop.travel Time.mktime(2011, 1, 2, 12, 2) do
        assert user.password_reset_expired?
      end
    end
  end
end
