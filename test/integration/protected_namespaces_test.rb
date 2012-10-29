require 'test_helper'

class ProtectedNamespacesTest < ActionDispatch::IntegrationTest
  fixtures :users
  
  def setup
    @andrea = users(:andrea) #non-admin
  end

  def teardown
    ActionMailer::Base.deliveries = []  
  end

  test "non admin can access wiki namespace" do
    cookies[:auth_token] = @andrea.auth_token
    get '/wiki/pages'
    assert_response :success
  end

  test "non admin can not access admin namespace" do
    cookies[:auth_token] = @andrea.auth_token
    get '/admin/products'
    assert_response :redirect
  end
end
