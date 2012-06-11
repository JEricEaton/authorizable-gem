module Authorizable
  class Configuration
    attr_accessor :mailer_sender, :cookie_expiration, :password_strategy, :user_model, 
                  :unauthorized_template, :public_resources, :password_salt,
                  :password_reset_token_column_name,
                  :inactive_account_sign_in_message, :halted_account_sign_in_message, :invalid_sign_in_message
                  

    def initialize
      @mailer_sender     = 'donotreply@example.com'
      @cookie_expiration = lambda { 1.year.from_now.utc }
      @unauthorized_template = 'unauthorized'
      @public_resources = {}
      @password_strategy = BcryptHashSecretStrategy
      @password_reset_token_column_name = 'reset_password_token'
      @inactive_account_sign_in_message = "Your account is inactive. Please find the email sent to you on sign up and follow the instructions."
      @halted_account_sign_in_message = "Your account has been halted. This is either due to you not paying your course fee or you violating the Terms of Use in other way."
      @invalid_sign_in_message = "Invalid email or password."
    end

    def user_model
      @user_model || ::User
    end
    
    def add_public_resource(contoller_with_actions)
      if contoller_with_actions.is_a?(String)
        public_resources[contoller_with_actions] = :all
      else
        public_resources.merge! contoller_with_actions
      end
    end
  end

  class << self
    attr_accessor :configuration
  end

  # Configure Authorizable someplace sensible,
  # like config/initializers/clearance.rb
  #
  # If you want users to only be signed in during the current session
  # instead of being remembered, do this:
  #
  #   config.cookie_expiration = lambda { }
  #
  # @example
  #   Authorizable.configure do |config|
  #     config.mailer_sender     = 'me@example.com'
  #     config.cookie_expiration = lambda { 2.weeks.from_now.utc }
  #     config.password_strategy = MyPasswordStrategy
  #     config.user_model        = MyNamespace::MyUser
  #   end
  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end
end
