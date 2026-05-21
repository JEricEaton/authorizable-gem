module Authorizable
  class UnauthorizedAccessError < StandardError; end

  class NonAdminNotAllowedToImpersonateError < StandardError; end
end
