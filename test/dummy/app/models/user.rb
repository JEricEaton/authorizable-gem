class User < ActiveRecord::Base
  attr_accessible :auth_token, :email, :first_name, :last_name, :password_digest, :password_reset_sent_at, :reset_password_token
end
