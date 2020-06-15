require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  fixtures :users

  test "edit is not publicly accessible, should give unauthorized status code and render the unauthorized template" do
    get :edit, params: { id: users(:robert).to_param }
    assert_response :redirect
    assert_redirected_to sign_in_path(r: edit_user_path(users(:robert).to_param))
  end
  
  test "blank remember me cookie does not authorize anyone" do
    @request.cookies[:auth_token] = ''
    get :edit, params: { id: users(:robert) }
    assert_response :redirect
    assert_nil @controller.current_user
    assert_nil assigns(:current_user)
  end
  
  test "spaces filled remember me cookie does not authorize anyone" do
    @request.cookies[:auth_token] = '   '
    get :edit, params: { id: users(:robert) }
    assert_response :redirect
    assert_nil @controller.current_user
    assert_nil assigns(:current_user)
  end
  
  test "remember me cookie carrying the auth_token present in the database authorizes the corresponding user" do
    @request.cookies[:auth_token] = 'RobertsAuthToken'
    get :edit, params: { id: users(:robert) }
    assert_response :success
    assert @controller.current_user
    assert assigns(:current_user)
  end

  test "when redirected to sign in after unauthorized access the params are also remembered" do
    get :edit, params: { id: users(:robert).id, something: 32 }
    r = "/users/#{users(:robert).id}/edit?something=32"
    assert_redirected_to sign_in_url(r: r)
  end
end
