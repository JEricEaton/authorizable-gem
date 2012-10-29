class ApplicationController < ActionController::Base
  protect_from_forgery
  
  include Authorizable::Authentication
  
  public_resources do
  end

  resources_for_role :product_manager do
    allow 'admin/products' => %w(index add edit destroy)
  end
  
  def redirect_to_after_sign_in
    '/users/' + current_user.to_param
  end
end
