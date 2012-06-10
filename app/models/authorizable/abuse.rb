module Authorizable
  class Abuse < ActiveRecord::Base
    self.table_name = 'abuses'
    
    def self.ip_banned?(ip_address)
      where(banned: true, ip_address: ip_address).exists?
    end
  end
end