require 'test_helper'

class ResourcesForRoleTest < ActionDispatch::IntegrationTest
  fixtures :users

  def setup
    @andrea = users(:andrea) #non-admin
    @my_cookies = ActionDispatch::Request.new(Rails.application.env_config.deep_dup).cookie_jar
  end

  def teardown
    ActionMailer::Base.deliveries = []
  end

  test "admin can access the admin resource that is also product_managers resource" do
    @my_cookies.encrypted[:auth_token] = users(:robert).auth_token
    cookies[:auth_token] = @my_cookies[:auth_token]
    get '/admin/products'
    assert_response :success
  end

  test "without product_manager or admin permissions you can not access product_managers resource" do
    @my_cookies.encrypted[:auth_token] = @andrea.auth_token
    cookies[:auth_token] = @my_cookies[:auth_token]
    get '/admin/products'
    assert_response :redirect
  end

  test "with product_manager permissions you can access product_managers resource allowed in ApplicationController" do
    @andrea.product_manager = true
    @andrea.save!
    @my_cookies.encrypted[:auth_token] = @andrea.auth_token
    cookies[:auth_token] = @my_cookies[:auth_token]
    get '/admin/products'
    assert_response :success
  end
end
