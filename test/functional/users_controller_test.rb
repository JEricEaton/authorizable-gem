require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  fixtures :users

  test "index is publicly accesible" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "edit is not publicly accessible, should give unauthorized status code and render the unauthorized template" do
    get :edit, id: users(:robert)
    assert_response :unauthorized
    assert_select 'h1', "Unauthorized access"
  end
  
  test "template in views/application should override the default template provided by the engine" do
    Authorizable.configuration.unauthorized_template = 'custom_unauthorized'
    get :edit, id: users(:robert)
    assert_response :unauthorized
    assert_select 'h1', "You're not allowed here dude!"
  end
end
