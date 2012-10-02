class ApplicationController < ActionController::Base
  protect_from_forgery
  
  include Authorizable::Authentication
  
  public_resources do
  end
  
  def redirect_to_after_sign_in
    '/users/' + current_user.to_param
  end
end
