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
    
    test "currrent password validation needs to be explicitly enabled to check for current password" do
      robert = users(:robert)
      invalid_password_update_params = { password: 'newPassword', password_confirmation: 'newPassword', current_password: '' }
      assert robert.update_attributes(invalid_password_update_params)
      assert robert.authenticate('newPassword')
    end
      
    test "with enabled current password validation empty or no valud does not pass" do
      robert = users(:robert)
      robert.validate_current_password = true
      
      invalid_password_update_params = { password: 'newPassword2', password_confirmation: 'newPassword2', current_password: '' }
      assert !robert.update_attributes(invalid_password_update_params)
      assert !robert.authenticate('newPassword2')
      
      invalid_password_update_params = { password: 'newPassword2', password_confirmation: 'newPassword2' }
      assert !robert.update_attributes(invalid_password_update_params)
      assert !robert.authenticate('newPassword2')
      
      invalid_password_update_params = { password: 'newPassword2', password_confirmation: 'newPassword2', current_password: nil }
      assert !robert.update_attributes(invalid_password_update_params)
      assert !robert.authenticate('newPassword2')
      
      invalid_password_update_params = { password: 'newPassword2', password_confirmation: 'newPassword2', current_password: 'invalid' }
      assert !robert.update_attributes(invalid_password_update_params)
      assert !robert.authenticate('newPassword2')
    end
      
    test "valid password update" do
      robert = users(:robert)
      robert.validate_current_password = true
      
      valid_password_update_params = { password: 'newPassword2', password_confirmation: 'newPassword2', current_password: 'antonio' }
      assert robert.update_attributes(valid_password_update_params)
      assert robert.authenticate('newPassword2')
    end
  end
end
