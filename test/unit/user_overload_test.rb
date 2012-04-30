# encoding: UTF-8
require 'test_helper'

module Authorizable
  class UserOverloadTest < ActiveSupport::TestCase
    fixtures :users
    
    class Stranger < ActiveRecord::Base
      self.table_name = 'users'
      LEGACY_SALT = 'whatever'
      
      # To emulate that the user has such a column in DB
      attr_accessor :password_hash
      
      include Authorizable::User
      
      PASSWORD_COLUMNS_AND_METHODS = {
        :current => [:password_digest, :digest_password],
        :legacy => [:password_hash, :legacy_digest_password]
      }
      
      def authenticate(password)
        domain = password_salt.present? ? :current : :legacy
        compare_to_column, digest_method = PASSWORD_COLUMNS_AND_METHODS[domain]
        send(compare_to_column) == send(digest_method, password)
      end

      def digest_password(password)
        BCrypt::Engine.hash_secret(password, password_salt)
      end
      
      def legacy_digest_password(password)
        Digest::SHA1.hexdigest(LEGACY_SALT + password)
      end

      def set_password_digest
        if password.present?
          self.password_salt = BCrypt::Engine.generate_salt
          self.password_digest = digest_password(password)
        end
        true
      end
    end
    
    test "authorize using a salt column" do
      niklas = Stranger.find_by_first_name 'Niklas'
      assert !niklas.authenticate('not-his-password')
      assert niklas.authenticate('keychain')
    end
    
    test "authorize using legacy sha1 password" do
      user = Stranger.new 
      user.password_hash = "5a02ec293d69c18983bd88cffbec4ec44521fa70"
      assert !user.authenticate('not-her-password')
      assert user.authenticate('protected')
    end
    
    test "before save, salt and password is generated" do
      user = Stranger.new
      user.password = 'security'
      user.email = 'me@equalmoney.org'
      assert user.save
      assert_not_empty user.password_salt
      assert_not_empty user.password_digest
    end
  end
end
