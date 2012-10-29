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
  
  # test "without product_manager permissions you can not access product_manager's resource" do
  #   path = '/admin/products'
  #   # Sign in
  #   visit '/sign_in'
  #   fill_in 'Email', :with => 'klevo@klevo.sk'
  #   fill_in 'Password', :with => 'antonio'
  #   click_button 'Sign in'
    
  #   assert_equal user_url(@robert), current_url
    
  #   # Sign out
  #   click_on 'Sign out'
  #   assert_equal sign_in_url, current_url
  # end
end
