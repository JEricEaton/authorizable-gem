module Authorizable
  class Abuse < ActiveRecord::Base
    self.table_name = 'abuses'
    BAN_ON_FAILED_ATTEMPTS_COUNT = 10
    
    def self.ip_banned?(ip_address)
      where(banned: true, ip_address: ip_address).exists?
    end
    
    def self.failed_attempt!(ip_address)
      ip = where(ip_address: ip_address).first
      if ip
        unless (ip.updated_at + 1.day) > Time.zone.now
          ip.failed_attempts = 0
        end 
        
        ip.failed_attempts += 1
      else
        ip = Abuse.new do |abuse|
          abuse.ip_address = ip_address
          abuse.failed_attempts = 1
          abuse.banned = false
        end
      end
      
      if ip.failed_attempts >= BAN_ON_FAILED_ATTEMPTS_COUNT
        ip.banned = true
      end
      
      ip.save
    end
  end
end