module Authorizable
  class Abuse < ActiveRecord::Base
    self.table_name = 'abuses'
    
    scope :banned, -> { where banned: true }
    
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
      
      if ip.failed_attempts >= Authorizable.configuration.ban_on_failed_attempts_count
        ip.banned = true
      end
      
      if ip.save
        ip
      else
        false
      end
    end
    
    def unban!
      self.failed_attempts = 0
      self.banned = false
      save!
    end
    
    def show_ban_warning?
      failed_attempts >= Authorizable.configuration.warn_after_failed_attempts_count
    end
    
    def remaining_attempts_count
      Authorizable.configuration.ban_on_failed_attempts_count - failed_attempts
    end
  end
end