class ApplicationController < ActionController::Base
  protect_from_forgery
  
  include Authorizable::Authentication

  # namespace_authorization_required_for :admin
  
  group_access :public do |a|
    a.allow 'pages' => %w(home)
  end

  group_access :product_manager do |a|
    a.allow 'admin/products' => %w(index add edit destroy)
  end
  
  def redirect_to_after_sign_in
    '/users/' + current_user.to_param
  end
end
