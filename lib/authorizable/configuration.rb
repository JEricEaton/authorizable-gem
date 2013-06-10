module Authorizable
  class Configuration
    attr_accessor :mailer_sender, :cookie_expiration, :password_strategy, :user_model, 
                  :unauthorized_template, :public_resources, :password_salt,
                  :password_reset_token_column_name,
                  :inactive_account_sign_in_message, :halted_account_sign_in_message, 
                  :invalid_sign_in_message, :failed_attempts_warning,
                  :ban_on_failed_attempts_count

    def initialize
      @mailer_sender     = 'donotreply@example.com'
      @unauthorized_template = 'unauthorized'
      @password_strategy = BcryptHashSecretStrategy
      @password_reset_token_column_name = 'reset_password_token'
      @inactive_account_sign_in_message = "Your account is inactive. Please find the email sent to you on sign up and follow the instructions."
      @halted_account_sign_in_message = "Your account has been halted due to inactivity and/or violation of the Terms of Use."
      @invalid_sign_in_message = "Invalid email or password."
      @failed_attempts_warning = "Warning: After %remaining_attempts_count% more failed login attempt you'll be banned. Rember: You can easily reset your password - follow the \"I forgot my password\" link on the bottom."
      @ban_on_failed_attempts_count = 10
    end

    def user_model
      @user_model || ::User
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
  #     config.password_strategy = MyPasswordStrategy
  #     config.user_model        = MyNamespace::MyUser
  #   end
  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end
end
