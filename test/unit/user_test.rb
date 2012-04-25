# encoding: UTF-8
require 'test_helper'

module Authorizable
  class ::User
    include Authorizable::User
  end
  
  class UserTest < ActiveSupport::TestCase
    fixtures :users
    
    def setup
      Authorizable.configuration.password_salt = "$2a$10$KXmN2Kad5jKuGqfai8UFJu"
    end
    
    test "module" do
      assert Authorizable::User.is_a?(Module)
    end
    
    test "can be authenticated using password matching password_digest in database" do
      robert = users(:robert)
      assert robert.authenticate('antonio')
    end
    
    test "can NOT be authenticated using password NOT matching password_digest in database" do
      robert = users(:robert)
      assert !robert.authenticate('notthere')
    end
  end
end
