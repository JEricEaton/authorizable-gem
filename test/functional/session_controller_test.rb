require 'test_helper'

module Authorizable
  class ::User
    include Authorizable::User
  end

  class SessionsControllerTest < ActionController::TestCase
    fixtures :users
    
    def setup
      Authorizable.configuration.password_salt = "$2a$10$fREDiaGGPkyyXBNXM/Ae/O"
    end

    test "new/sign in is publicly accessible" do
      get :new
      assert_response :success
    end
  
    test "succesful sign in with email and password" do
      post :create, session: { email: 'klevo@klevo.sk', password: 'antonio' }
      assert_redirected_to '/users/' + users(:robert).to_param # Defined in dummy's ApplicationController#redirect_to_after_sign_in
    end
  end
end
