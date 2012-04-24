class ApplicationController < ActionController::Base
  protect_from_forgery
  
  include Authorizable::Authentication
  
  public_resources do
    allow 'users' => %w(index)
  end
end
