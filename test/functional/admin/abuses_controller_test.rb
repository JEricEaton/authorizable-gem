require 'test_helper'

class Admin::AbusesControllerTest < ActionController::TestCase
  set_fixture_class abuses: Authorizable::Abuse
  fixtures :abuses
  
  def setup
    @request.cookies[:auth_token] = 'RobertsAuthToken'
    super
  end
  
  test "index" do
    get :index
    assert_response :success
    assert_template :index
    assert assigns(:banned)
    assert_equal 1, assigns(:banned).count
    assert assigns(:banned).include?(abuses(:john))
  end

  test "unban" do
    assert Authorizable::Abuse.ip_banned?("111.11.11.11")
    
    post :unban, id: abuses(:john).id
    assert_response :redirect
    assert_redirected_to [:admin, :abuses]
    
    # binding.pry
    refute Authorizable::Abuse.ip_banned?("111.11.11.11")
  end
end