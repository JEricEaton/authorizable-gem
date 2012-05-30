module Authorizable
  class UnathorizedAccessError < StandardError; end
  
  class NonAdminNotAllowedToImpersonateError < StandardError; end
end