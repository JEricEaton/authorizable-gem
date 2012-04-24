# encoding: UTF-8
require 'test_helper'

module Authorizable
  class AuthenticationTest < ActiveSupport::TestCase
    test "module" do
      assert Authentication.is_a?(Module)
    end
  end
end
