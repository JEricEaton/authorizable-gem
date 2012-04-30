# encoding: UTF-8
require 'test_helper'

module Authorizable
  class UserOverloadTest < ActiveSupport::TestCase
    fixtures :users
    
    class Stranger < ActiveRecord::Base
      self.table_name = 'users'
      
      include Authorizable::User
      
      def authenticate(password)
        password_digest == digest_password(password)
      end

      def digest_password(password)
        Authorizable.configuration.password_strategy.digest password
      end

      def set_password_digest
        if password.present?
          self.password_digest = digest_password(password)
        end
        true
      end
    end
    
    # def setup
    #   Authorizable.configuration.password_salt = "$2a$10$fREDiaGGPkyyXBNXM/Ae/O"
    # end
    
    test "authorize using a salt from the database" do
      niklas = Stranger.find_by_first_name 'Niklas'
      assert !niklas.authenticate('not-his-password')
    end
    
  end
end
