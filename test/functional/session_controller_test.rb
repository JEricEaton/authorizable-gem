require 'test_helper'

module Authorizable
  class ::User
    include Authorizable::User
  end

  class SessionsControllerTest < ActionController::TestCase
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
end
