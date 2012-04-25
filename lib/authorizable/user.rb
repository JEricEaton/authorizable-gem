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
  end
end
