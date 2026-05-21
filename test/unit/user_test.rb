require 'test_helper'

module Authorizable
  class UserTest < ActiveSupport::TestCase
    fixtures :users

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

    test "with current password validation no valid does not pass" do
      robert = users(:robert)

      invalid_password_update_params = { password: 'newPassword23', password_challenge: '' }
      assert !robert.update(invalid_password_update_params)
      assert !robert.reload.authenticate('newPassword23')

      invalid_password_update_params = { password: 'newPassword2', password_challenge: 'invalid' }
      assert !robert.update(invalid_password_update_params)
      assert !robert.reload.authenticate('newPassword2')
    end

    test "valid password update" do
      robert = users(:robert)

      valid_password_update_params = { password: 'newPassword2', password_challenge: 'antonio' }
      assert robert.update!(valid_password_update_params)
      assert robert.authenticate('newPassword2')
    end
  end
end
