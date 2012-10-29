class ApplicationController < ActionController::Base
  protect_from_forgery
  
  include Authorizable::Authentication
  
  resources_for :public do |r|
    r.allow 'pages' => %w(home)
  end

  resources_for :product_manager do |r|
    r.allow 'admin/products' => %w(index add edit destroy)
  end
  
  def redirect_to_after_sign_in
    '/users/' + current_user.to_param
  end
end
