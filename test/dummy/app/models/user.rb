class User < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  include Authorizable::User  

  def access_roles
    [].tap do |allowed|
      allowed << :admin if admin?
      allowed << :product_manager if product_manager?
    end
  end
end
