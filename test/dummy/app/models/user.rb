class User < ActiveRecord::Base
  include Authorizable::User  
end
