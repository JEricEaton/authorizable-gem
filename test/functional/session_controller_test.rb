require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  fixtures :users

  def setup
    @robert = users(:robert)
  end

  test 'new/sign in is publicly accessible' do
    get :new
    assert_response :success
  end

  test 'successful sign in with email and password' do
    post :create, params: { session: { email: 'klevo@klevo.sk', password: 'antonio' } }
    assert_redirected_to @robert # Defined in dummy's ApplicationController#redirect_to_after_sign_in
  end

  test 'failed sign in' do
    post :create, params: { session: { email: 'klevo@klevo.sk', password: 'invalid' } }
    assert_response :unprocessable_entity
    assert_match(/invalid/i, flash[:alert])
  end

  test 'if r parameter is provided, redirect there' do
    post :create, params: { session: { email: 'klevo@klevo.sk', password: 'antonio', r: new_user_path } }
    assert_redirected_to new_user_path
  end

  test 'does not allow to redirect to as return to external domain' do
    post :create, params: { session: { email: 'klevo@klevo.sk', password: 'antonio', r: 'http://stackoverflow.com/questions/6714196/ruby-url-encoding-string' } }
    assert_redirected_to @robert
  end

  test 'sign out - removes cookie' do
    @my_cookies = ActionDispatch::Request.new(Rails.application.env_config.deep_dup).cookie_jar
    @my_cookies.encrypted[:user] = @robert.id # auth as Robert
    cookies[:user] = @my_cookies[:user]
    delete :destroy
    assert @response.header['Set-Cookie'].include?('user=; path=/; max-age=0; expires=Thu'),
           'Remember me cookie gets deleted'
  end

  test '10 failed sign-ins result in a ban' do
    1.upto(10).each do |attempts|
      refute Authorizable::Abuse.ip_banned?('0.0.0.0'), "Attempts: #{attempts}"

      post :create, params: { session: { email: 'klevo@klevo.sk', password: 'invalid' } }

      if attempts >= Authorizable.configuration.ban_on_failed_attempts_count
        assert_response :forbidden
        assert_template :banned
      else
        assert_response :unprocessable_entity
        assert_template :new

        if attempts >= Authorizable.configuration.warn_after_failed_attempts_count
          assert_match(/warning/i, @controller.flash[:alert], 'warn the user that he will be banned')
        else
          assert_match(/invalid/i, @controller.flash[:alert], 'just a msg that your login/pass is invalid')
        end
      end
    end

    assert Authorizable::Abuse.ip_banned?('0.0.0.0'), 'After 10 failed login attempts the IP is banned'

    post :create, params: { session: { email: 'klevo@klevo.sk', password: 'invalid' } }
    assert_response :forbidden
    assert_template :banned
  end

  test 'if banned, IP can not sign in' do
    Authorizable::Abuse.create do |abuse|
      abuse.ip_address = '0.0.0.0'
      abuse.banned = true
    end

    post :create, session: { email: 'klevo@klevo.sk', password: 'antonio' }
    assert_response :forbidden
  end

  test 'if impersonating, sign out stops the impersonation' do
    @andrea = users(:andrea)
    @my_cookies = ActionDispatch::Request.new(Rails.application.env_config.deep_dup).cookie_jar
    @my_cookies.encrypted[:user] = @robert.id # auth as Robert
    cookies[:user] = @my_cookies[:user]

    session[:impersonated_user_id] = @andrea.id

    delete :destroy

    @robert.reload
    assert_equal @robert.id, @robert.id
    assert_equal @robert.id, cookies.encrypted[:user]
  end
end
