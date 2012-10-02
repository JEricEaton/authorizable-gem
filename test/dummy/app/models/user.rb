class User < ActiveRecord::Base
  include Authorizable::User  

  attr_accessible :first_name, :last_name, :password, :password_confirmation, :email
end
