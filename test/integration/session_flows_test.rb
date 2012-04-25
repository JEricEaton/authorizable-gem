require 'test_helper'

class SessionFlowsTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  fixtures :users
  
  test "sign in, sign out" do
    # Sign in
    visit '/sign_in'
    fill_in 'Email', :with => 'klevo@klevo.sk'
    fill_in 'Password', :with => 'antonio'
    click_button 'Sign in'
    
    assert_equal user_url(users(:robert)), current_url
    
    # Sign out
    click_on 'Sign out'
    assert_equal sign_in_url, current_url
  end
end
