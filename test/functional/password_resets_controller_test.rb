require 'test_helper'

class PasswordResetsControllerTest < ActionController::TestCase
  fixtures :users

  def setup
    Authorizable.configuration.password_salt = "$2a$10$fREDiaGGPkyyXBNXM/Ae/O"
  end

  def teardown
    ActionMailer::Base.deliveries = []
  end

  test "new" do
    get :new
    assert :success
  end

  test "create" do
    now = Time.mktime(2012, 1, 1)
    travel_to now do
      post :create, email: 'klevo@klevo.sk'
    end
    user = users(:robert)
    assert_equal now, user.password_reset_sent_at

    assert_equal 1, ActionMailer::Base.deliveries.count
    email = ActionMailer::Base.deliveries.first
    assert_equal [users(:robert).email], email.to
    assert_match "Reset Instructions", email.subject
  end

  test "edit with proper token" do
    user = users(:robert)
    user.update_attribute :reset_password_token, 'resetme'
    get :edit, id: 'resetme'
    assert_response :success
  end

  test "edit with invalid token" do
    assert_raise ActiveRecord::RecordNotFound do
      get :edit, id: 'resetme'
    end
  end

  test "valid update" do
    now = Time.mktime(2012, 1, 1, 1, 0, 0)
    user = users(:robert)
    user.update_attribute :reset_password_token, 'resetme'
    user.update_attribute :password_reset_sent_at, Time.mktime(2012, 1, 1, 0, 0, 0)
    params = {
      password: 'NewRock',
      password_confirmation: 'NewRock'
    }
    travel_to now do
      post :update, user: params, id: 'resetme'
    end
    assert_redirected_to sign_in_path
    user.reload
    assert_not_equal '$2a$10$fREDiaGGPkyyXBNXM/Ae/OqbgBtlJ0tNqJYGJHgZg.tAvOEpJS.gK', user.password_digest
  end

  test "invalid update" do
    now = Time.mktime(2012, 1, 1, 1, 0, 0)
    user = users(:robert)
    user.update_attribute :reset_password_token, 'resetme1'
    user.update_attribute :password_reset_sent_at, Time.mktime(2012, 1, 1, 0, 0, 0)
    params = {
      password: 'NewRock',
      password_confirmation: 'NewRock'
    }
    travel_to now do
      assert_raise ActiveRecord::RecordNotFound do
        post :update, user: params, id: 'resetme'
      end
    end
  end

  test "on update should give validation error if passwords does not match" do
    now = Time.mktime(2012, 1, 1, 1, 0, 0)
    user = users(:robert)
    user.update_attribute :reset_password_token, 'resetme1'
    user.update_attribute :password_reset_sent_at, Time.mktime(2012, 1, 1, 0, 0, 0)
    params = {
      password: 'NewRock1',
      password_confirmation: 'NewRock'
    }
    travel_to now do
      post :update, user: params, id: 'resetme1'
    end
    user.reload
    assert_equal '$2a$10$fREDiaGGPkyyXBNXM/Ae/OqbgBtlJ0tNqJYGJHgZg.tAvOEpJS.gK', user.password_digest
    assert_match "doesn't match Password", assigns(:user).errors[:password_confirmation].first
  end
end
