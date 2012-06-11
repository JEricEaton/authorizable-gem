# encoding: UTF-8
require 'test_helper'

module Authorizable
  class AbuseTest < ActiveSupport::TestCase
    fixtures :abuses

    test "reset failed attempts after 1 day" do
      ip = '222.2222.111'
      
      Timecop.travel Time.mktime(2012, 1, 1) do
        Abuse.failed_attempt! ip
        Abuse.failed_attempt! ip
        Abuse.failed_attempt! ip
        
        abuse = Abuse.find_by_ip_address ip
        assert_equal 3, abuse.failed_attempts
      end
      
      Timecop.travel Time.mktime(2012, 1, 2, 1) do
        Abuse.failed_attempt! ip

        abuse = Abuse.find_by_ip_address ip
        assert_equal 1, abuse.failed_attempts
      end
    end
  end
end
