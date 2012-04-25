# encoding: UTF-8
require 'test_helper'

module Authorizable
  class Tester < ActiveRecord::Base
    self.table_name = 'users'
    include Authorizable::User
  end
  
  class UserTest < ActiveSupport::TestCase
    test "module" do
      assert Authorizable::User.is_a?(Module)
    end
    
    def setup
      @subject = Tester.new
    end
    
    test "something interesting" do
      
    end
  end
end
