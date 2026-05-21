require 'test_helper'

class PasswordResetsControllerTest < ActionController::TestCase
  fixtures :users

  def teardown
    ActionMailer::Base.deliveries = []
  end

  test "new" do
    get :new
    assert :success
  end

  test "create with existing email" do
    post :create, params: { email: 'klevo@klevo.sk' }
    assert_equal 1, ActionMailer::Base.deliveries.count
    email = ActionMailer::Base.deliveries.first
    assert_equal [users(:robert).email], email.to
    assert_match "Reset Instructions", email.subject
    reset_path = email.body.raw_source.scan(/http.*?\/edit/).first
    assert reset_path.present?
    assert_redirected_to new_password_reset_path
    assert_equal 'Email sent with password reset instructions. Please check your email inbox.', flash[:notice]
  end

  test "create non existent email" do
    post :create, params: { email: 'notfound@example.com' }
    assert_equal 0, ActionMailer::Base.deliveries.count
    assert_redirected_to new_password_reset_path
    assert_equal 'Email address not found, please try again.', flash[:alert]
  end

  test "edit with proper token" do
    user = users(:robert)
    token = user.password_reset_token
    get :edit, params: { id: token }
    assert_response :success
  end

  test "valid update" do
    user = users(:robert)
    token = user.password_reset_token
    params = {
      password: 'NewRock123',
      password_confirmation: 'NewRock123'
    }
    post :update, params: { user: params, id: token }
    assert_redirected_to sign_in_path
    user.reload
    assert user.authenticate("NewRock123")
  end

  test "invalid update" do
    params = {
      password: 'NewRock',
      password_confirmation: 'NewRock'
    }

    post :update, params: { user: params, id: 'resetme' }
    assert_redirected_to new_password_reset_path
    assert_equal 'Invalid Reset token, please try again!', flash[:alert]
  end

  test "on update should give validation error if passwords does not match" do
    user = users(:robert)
    token = user.password_reset_token
    params = {
      password: 'NewRock1',
      password_confirmation: 'NewRock'
    }
    post :update, params: { user: params, id: token }
    user.reload
    assert_match "doesn't match Password", assigns(:user).errors[:password_confirmation].first
    assert user.authenticate("antonio")
  end

  test "Password reset token expired" do
    user = users(:robert)
    token = user.password_reset_token
    params = {
      password: 'NewRock1',
      password_confirmation: 'NewRock1'
    }
    travel_to 20.minutes.from_now do
      post :update, params: { user: params, id: token }
      user.reload
      assert_redirected_to new_password_reset_path
      assert_equal 'Invalid Reset token, please try again!', flash[:alert]
      assert user.authenticate("antonio")
    end
  end
end
