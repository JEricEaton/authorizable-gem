class User < ActiveRecord::Base
  include Authorizable::User  

  attr_accessible :first_name, :last_name, :password, :password_confirmation, :email

  def access_to_route_namespaces
    [].tap do |allowed|
      allowed << :admin if admin?
      allowed << :product_manager if product_manager?
    end
  end
end
