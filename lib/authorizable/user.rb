require 'bcrypt'

# Usage: Include Authorizable::User in your User model
module Authorizable
  module User
    extend ActiveSupport::Concern
  
    included do
     
    end
  
    module ClassMethods

    end
  
    def authenticate(password)
      password_digest == digest_password(password)
    end
    
    def digest_password(password)
      BCrypt::Engine.hash_secret(password, Authorizable.configuration.password_salt) 
    end
    
    def regenerate_auth_token
      generate_token :auth_token, 180 # generates string with length of 240
      save! validate: false
    end

    def generate_token(column, length)
      begin  
        self[column] = SecureRandom.urlsafe_base64(length)
      end while Authorizable.configuration.user_model.exists?(column => self[column])
    end
  end
end
