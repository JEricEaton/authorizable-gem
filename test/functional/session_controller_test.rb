require 'test_helper'

class Authorizable::SessionsControllerTest < ActionController::TestCase
  fixtures :users

  test "new/sign in is publicly accessible" do
    get :new
    assert_response :success
  end
  
  # test "succesful sign in" do
  #   post :create, session: { email: 'klevo@klevo.sk', password: 'antonio' }
  #   
  # end
end
