require 'bcrypt'

# Usage: Include Authorizable::User in your User model
module Authorizable
  module User
    extend ActiveSupport::Concern
  
    included do
      attr_accessor :password, :current_password, :force_password_validation
      attr_accessible :password, :current_password, :password_confirmation
      
      validates :email, 
        presence: true, 
        uniqueness: true, 
        email_format: true
      validates :password, 
        presence: true, 
        confirmation: true, 
        length: { minimum: 6, message: 'must be at least 6 characters long' }, 
        :if => lambda { new_record? || current_password.present? || force_password_validation }
      validates :current_password, 
        current_password_matches: true, 
        :if => lambda { current_password.present? }
        
      before_save :set_password_digest
    end
  
    def authenticate(password)
      password_digest == digest_password(password)
    end
    
    def digest_password(password)
      Authorizable.configuration.password_strategy.digest password
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
    
    def create_password_reset_token  
      generate_token :reset_password_token, 10
      self.password_reset_sent_at = Time.now
      save!
    end
    
    def set_password_digest
      if password.present?
        self.password_digest = digest_password(password)
      end
      true
    end
  end
end
