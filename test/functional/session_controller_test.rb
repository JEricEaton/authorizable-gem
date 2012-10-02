require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  fixtures :users
  
  def setup
    Authorizable.configuration.password_salt = "$2a$10$fREDiaGGPkyyXBNXM/Ae/O"
    @robert = users(:robert)
  end

  test "new/sign in is publicly accessible" do
    get :new
    assert_response :success
  end

  test "succesful sign in with email and password" do
    post :create, session: { email: 'klevo@klevo.sk', password: 'antonio' }
    assert_redirected_to @robert # Defined in dummy's ApplicationController#redirect_to_after_sign_in
    
    @robert.reload
    assert_not_equal @robert.auth_token, "RobertsAuthToken", 'auth_token has been regenerated'
  end
  
  test "failed sign in" do
    post :create, session: { email: 'klevo@klevo.sk', password: 'invalid' }
    assert_response :success
    assert_equal @robert.auth_token, "RobertsAuthToken", 'auth_token has not been regenerated'
    assert_match /invalid/i, flash[:alert]
  end

  test "if r parameter is provided, redirect there" do
    post :create, session: { email: 'klevo@klevo.sk', password: 'antonio', r: new_user_path }
    assert_redirected_to new_user_path
  end

  test "does not allow to redirect to as return to external domain" do
    post :create, session: { email: 'klevo@klevo.sk', password: 'antonio', r: "http://stackoverflow.com/questions/6714196/ruby-url-encoding-string" }
    assert_redirected_to @robert
  end
  
  test "sign out - resets auth_token field and removes cookie" do
    @request.cookies[:auth_token] = 'RobertsAuthToken'
    delete :destroy
    @robert.reload
    assert_equal @robert.auth_token, '', 'auth_token has been emptied'
    assert_equal "auth_token=; path=/; expires=Thu, 01-Jan-1970 00:00:00 GMT", @response.header['Set-Cookie'], 'Remember me cookie gets deleted'
  end
  
  test "10 failed sign-ins result in a ban" do
    1.upto(10).each do
      assert !Authorizable::Abuse.ip_banned?("0.0.0.0")
      post :create, session: { email: 'klevo@klevo.sk', password: 'invalid' }
    end
    
    assert Authorizable::Abuse.ip_banned?("0.0.0.0"), 'After 10 failed login attempts the IP is banned'
  end
  
  test "if banned, IP can not sign in" do
    Authorizable::Abuse.create do |abuse|
      abuse.ip_address = "0.0.0.0"
      abuse.banned = true
    end
    
    post :create, session: { email: 'klevo@klevo.sk', password: 'antonio' }
    assert_response :forbidden
  end
end

