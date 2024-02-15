require 'bcrypt'

# Usage: Include Authorizable::User in your User model
module Authorizable
  module User
    extend ActiveSupport::Concern

    included do
      attr_accessor :password, :current_password, :force_password_validation, :validate_current_password

      validates :email,
                presence: true,
                uniqueness: true,
                email_format: true
      validates :password,
                presence: true,
                confirmation: true,
                length: { minimum: 6, message: 'must be at least 6 characters long' },
                if: -> { new_record? || current_password.present? || force_password_validation }
      validates :current_password,
                current_password_matches: true,
                if: -> { validate_current_password }

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

    def generate_token(column, length = 180)
      begin
        self[column] = SecureRandom.urlsafe_base64(length)
      end while Authorizable.configuration.user_model.exists?(column => self[column])
    end

    def create_password_reset_token
      generate_token Authorizable.configuration.password_reset_token_column_name.to_sym, 10
      self.password_reset_sent_at = Time.now
      save!
    end

    def set_password_digest
      self.password_digest = digest_password(password) if password.present?
      true
    end

    def password_reset_expired?
      (password_reset_sent_at + 2.hours) < Time.zone.now
    end

    def can_sign_in_as?(_user)
      admin?
    end
  end
end
