require 'test_helper'

class ImpersonationsControllerTest < ActionController::TestCase
  fixtures :users
  
  def setup
    Authorizable.configuration.password_salt = "$2a$10$fREDiaGGPkyyXBNXM/Ae/O"
    @robert = users(:robert)
    @andrea = users(:andrea)
  end
  
  test "create - Robert (admin) starts impersonating Andrea" do
    @request.cookies[:auth_token] = 'RobertsAuthToken' # auth as Robert
    
    assert_nil session[:impersonated_user_id]
    
    post :create, user_id: @andrea.id
    assert_response :redirect
    assert_redirected_to root_path
    assert_equal @andrea.id, session[:impersonated_user_id]
    assert_equal @andrea, @controller.current_user
  end
  
  test "anonymous user is not allowed to impersonate" do
    assert_nil @request.cookies[:auth_token]
    post :create, user_id: @andrea.id
    assert_response :redirect
  end
  
  test "non admin is not allowed to impersonate" do
    cookies[:auth_token] = 'AndreasAuthToken' # auth as Andrea
    
    assert_raise Authorizable::NonAdminNotAllowedToImpersonateError do
      post :create, user_id: @robert.id
    end
  end
  
  test "stop impersonation" do
    @request.cookies[:auth_token] = 'RobertsAuthToken' # auth as Robert
    session[:impersonated_user_id] = @andrea.id
    post :stop
    assert_nil session[:impersonated_user_id]
    assert_equal @robert, @controller.current_user
  end
end