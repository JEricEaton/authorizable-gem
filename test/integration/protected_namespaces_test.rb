require 'test_helper'

class ProtectedNamespacesTest < ActionDispatch::IntegrationTest
  fixtures :users

  def setup
    @andrea = users(:andrea) #non-admin
    @my_cookies = ActionDispatch::Request.new(Rails.application.env_config.deep_dup).cookie_jar
    @my_cookies.encrypted[:auth_token] = @andrea.auth_token
    cookies[:auth_token] = @my_cookies[:auth_token]
  end

  def teardown
    ActionMailer::Base.deliveries = []
  end

  test "non admin can access wiki namespace" do
    get '/wiki/pages'
    assert_response :success
  end

  test "non admin can not access admin namespace" do
    get '/admin/products'
    assert_response :redirect
  end
end
