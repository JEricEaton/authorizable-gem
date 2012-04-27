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
    Timecop.travel now
    params = {
      email: 'klevo@klevo.sk',
    }
    post :create, params
    user = users(:robert)
    assert_equal now, user.password_reset_sent_at
    Timecop.return
    
    assert_equal 1, ActionMailer::Base.deliveries.count
    email = ActionMailer::Base.deliveries.first
    assert_equal [users(:robert).email], email.to
    assert_match /Reset Instructions/, email.subject
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
    Timecop.travel now
    user = users(:robert)
    user.update_attribute :reset_password_token, 'resetme'
    user.update_attribute :password_reset_sent_at, Time.mktime(2012, 1, 1, 0, 0, 0)
    params = {
      password: 'NewRock',
      password_confirmation: 'NewRock'
    }
    post :update, user: params, id: 'resetme'
    assert_redirected_to sign_in_path
    user.reload
    assert_equal '$2a$10$KXmN2Kad5jKuGqfai8UFJuf9a3BcDC7kWMcujWPmo2PXqODg5vJo2', user.password_digest
    Timecop.return
  end
  
  test "invalid update" do
    now = Time.mktime(2012, 1, 1, 1, 0, 0)
    Timecop.travel now
    user = users(:robert)
    user.update_attribute :reset_password_token, 'resetme1'
    user.update_attribute :password_reset_sent_at, Time.mktime(2012, 1, 1, 0, 0, 0)
    params = {
      password: 'NewRock',
      password_confirmation: 'NewRock'
    }
    assert_raise ActiveRecord::RecordNotFound do
      post :update, user: params, id: 'resetme'
    end
    Timecop.return
  end
  
  test "on update should give validation error if passwords does not match" do
    now = Time.mktime(2012, 1, 1, 1, 0, 0)
    Timecop.travel now
    user = users(:robert)
    user.update_attribute :reset_password_token, 'resetme1'
    user.update_attribute :password_reset_sent_at, Time.mktime(2012, 1, 1, 0, 0, 0)
    params = {
      password: 'NewRock1',
      password_confirmation: 'NewRock'
    }
    post :update, user: params, id: 'resetme1'
    user.reload
    assert_equal '$2a$10$KXmN2Kad5jKuGqfai8UFJuz3lYPj.NRKy9zZX9H5Jd/ncrVLaDIGy', user.password_digest
    assert_match /confirmation/, assigns(:user).errors[:password].first
    Timecop.return
  end
end
