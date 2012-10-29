require 'test_helper'

class ResourcesForRoleTest < ActionDispatch::IntegrationTest
  fixtures :users
  
  def setup
    @andrea = users(:andrea) #non-admin
  end

  def teardown
    ActionMailer::Base.deliveries = []  
  end

  test "admin can access the admin resource that is also product_managers resource" do
    cookies[:auth_token] = users(:robert).auth_token
    get '/admin/products'
    assert_response :success
  end
  
  test "without product_manager or admin permissions you can not access product_managers resource" do
    cookies[:auth_token] = @andrea.auth_token
    get '/admin/products'
    assert_response :redirect
  end
end
