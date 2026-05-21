require 'test_helper'

class SessionFlowsTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  fixtures :users

  def setup
    @robert = users(:robert)
  end

  def teardown
    ActionMailer::Base.deliveries = []
  end

  test "sign in, sign out" do
    # Sign in
    visit '/sign_in'
    fill_in 'Email', with: 'klevo@klevo.sk'
    fill_in 'Password', with: 'antonio'
    click_button 'Sign in'

    assert_equal user_url(@robert), current_url

    # Sign out
    click_on 'Sign out'
    assert_equal sign_out_url, current_url
  end

  test "reset forgotten password, then sign in with the new one" do
    visit '/sign_in'
    click_on 'I forgot my password'
    assert_equal new_password_reset_url, current_url

    fill_in 'email', with: 'klevo@klevo.sk'
    click_button 'Send me password reset instructions'

    assert_equal 1, ActionMailer::Base.deliveries.size
    email = ActionMailer::Base.deliveries.first
    assert_equal [@robert.email], email.to
    assert_match(/Reset Instructions/, email.subject)
    reset_path = email.body.raw_source.scan(/http.*?\/edit/).first

    # Reset the password
    visit reset_path
    find('#user_password').set 'newpass123'
    find('#user_password_confirmation').set 'newpass123'
    click_button 'Save my new password'

    # After password reset we land on sign in screen
    assert_equal sign_in_path, current_path

    # Sign in with the new password
    fill_in 'Email', with: 'klevo@klevo.sk'
    fill_in 'Password', with: 'newpass123'
    click_button 'Sign in'

    assert_equal user_path(@robert), current_path
  end
end
