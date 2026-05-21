module Authorizable
  class Configuration
    attr_accessor :mailer_sender, :cookie_expiration, :user_model,
                  :unauthorized_template, :public_resources, :deprecated_password_salt,
                  :inactive_account_sign_in_message, :halted_account_sign_in_message,
                  :invalid_sign_in_message, :failed_attempts_warning,
                  :ban_on_failed_attempts_count, :warn_after_failed_attempts_count

    def initialize
      @mailer_sender = 'donotreply@example.com'
      @unauthorized_template = 'unauthorized'
      @inactive_account_sign_in_message = 'Your account is inactive. Please find the email sent to you on sign up and follow the instructions.'
      @halted_account_sign_in_message = 'Your account has been halted due to inactivity and/or violation of the Terms of Use.'
      @invalid_sign_in_message = 'Invalid email or password.'
      @failed_attempts_warning = "Warning: After %remaining_attempts_count% more failed login attempts you'll be banned. Remember: You can easily reset your password - follow the \"I forgot my password\" link on the bottom."
      @ban_on_failed_attempts_count = 10
      @warn_after_failed_attempts_count = 3
    end

    def user_model
      if defined? @user_model
        @user_model
      else
        ::User
      end
    end
  end

  class << self
    attr_accessor :configuration
  end

  # Configure Authorizable someplace sensible,
  # like config/initializers/authorizable.rb
  #
  # @example
  #   Authorizable.configure do |config|
  #     config.mailer_sender     = 'me@example.com'
  #     config.user_model        = MyNamespace::MyUser
  #   end
  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end
end
