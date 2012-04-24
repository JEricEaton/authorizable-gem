require 'test_helper'

class AuthorizableTest < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, Authorizable
  end
end
