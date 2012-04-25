module Authorizable
  class Configuration
    attr_accessor :mailer_sender, :cookie_expiration, :password_strategy, :user_model, 
                  :unauthorized_template, :public_resources

    def initialize
      @mailer_sender     = 'donotreply@example.com'
      @cookie_expiration = lambda { 1.year.from_now.utc }
      @unauthorized_template = 'unauthorized'
      @public_resources = {}
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
