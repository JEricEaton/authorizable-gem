# Usage: Include Authorizable::User in your User model
module Authorizable
  module User
    extend ActiveSupport::Concern

    included do
      has_secure_password
      validates :email,
                presence: true,
                uniqueness: true,
                format: { with: URI::MailTo::EMAIL_REGEXP }
      validates :password,
                length: { minimum: 8, message: 'must be at least 8 characters long' },
                if: -> { password.present? }

      # Rails 7.2 does not include handling for password reset tokens
      def password_reset_token
        generate_token_for(:password_reset)
      end

      generates_token_for :password_reset, expires_in: 15.minutes do
        public_send(:password_salt)&.last(10)
      end

      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        silence_redefinition_of_method :find_by_password_reset_token
        def self.find_by_password_reset_token(token)
          find_by_token_for(:password_reset, token)
        end

        silence_redefinition_of_method :find_by_password_reset_token!
        def self.find_by_password_reset_token!(token)
          find_by_token_for!(:password_reset, token)
        end
      RUBY

      # end of reset handling to be removed in Rails v8
    end

    def can_sign_in_as?(_user)
      admin?
    end
  end
end
