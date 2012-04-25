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
    assert_redirected_to '/users/' + @robert.to_param # Defined in dummy's ApplicationController#redirect_to_after_sign_in
    
    @robert.reload
    assert_not_equal @robert.auth_token, "RobertsAuthToken", 'auth_token has been regenerated'
  end
  
  test "failed sign in" do
    post :create, session: { email: 'klevo@klevo.sk', password: 'invalid' }
    assert_response :success
    assert_equal @robert.auth_token, "RobertsAuthToken", 'auth_token has not been regenerated'
    assert_match /invalid/i, flash[:alert]
  end
  
  test "sign out - resets auth_token field and removes cookie" do
    @request.cookies[:auth_token] = 'RobertsAuthToken'
    delete :destroy
    @robert.reload
    assert_equal @robert.auth_token, '', 'auth_token has been emptied'
    assert_equal "auth_token=; path=/; expires=Thu, 01-Jan-1970 00:00:00 GMT", @response.header['Set-Cookie'], 'Remember me cookie gets deleted'
  end
end

