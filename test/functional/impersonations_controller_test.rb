require 'test_helper'

class ImpersonationsControllerTest < ActionController::TestCase
  fixtures :users
  
  def setup
    Authorizable.configuration.password_salt = "$2a$10$fREDiaGGPkyyXBNXM/Ae/O"
    @robert = users(:robert)
    @andrea = users(:andrea)
  end
  
  test "create" do
    assert true
  end
end