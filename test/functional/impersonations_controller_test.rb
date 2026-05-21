require 'test_helper'

class ImpersonationsControllerTest < ActionController::TestCase
  fixtures :users

  def setup
    @robert = users(:robert)
    @andrea = users(:andrea)
    @my_cookies = ActionDispatch::Request.new(Rails.application.env_config.deep_dup).cookie_jar
  end

  test "create - Robert (admin) starts impersonating Andrea" do
    @my_cookies.encrypted[:user] = @robert.id # auth as Robert
    cookies[:user] = @my_cookies[:user]

    assert_nil session[:impersonated_user_id]

    post :create, params: { user_id: @andrea.id }
    assert_response :redirect
    assert_redirected_to root_path
    assert_equal @andrea.id, session[:impersonated_user_id]
    assert_equal @andrea, @controller.current_user
  end

  test "anonymous user is not allowed to impersonate" do
    assert_nil cookies.encrypted[:user]
    post :create, params: { user_id: @andrea.id }
    assert_response :redirect
  end

  test "non admin is not allowed to impersonate" do
    @my_cookies.encrypted[:user] = @andrea.id # auth as Andrea
    cookies[:user] = @my_cookies[:user]

    assert_raise Authorizable::NonAdminNotAllowedToImpersonateError do
      post :create, params: { user_id: @robert.id }
    end
  end

  test "stop impersonation" do
    @my_cookies.encrypted[:user] = @robert.id # auth as Robert
    cookies[:user] = @my_cookies[:user]
    session[:impersonated_user_id] = @andrea.id
    post :stop
    assert_nil session[:impersonated_user_id]
    assert_equal @robert, @controller.current_user
  end
end
