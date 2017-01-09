module Berta
  module Errors
    # Module for OpenNebula error classes
    module OpenNebula
      autoload :StubError, 'berta/errors/opennebula/stub_error'
      autoload :AuthenticationError, 'berta/errors/opennebula/authentication_error'
      autoload :UserNotAuthorizedError, 'berta/errors/opennebula/user_not_authorized_error'
      autoload :ResourceNotFoundError, 'berta/errors/opennebula/resource_not_found_error'
      autoload :ResourceStateError, 'berta/errors/opennebula/resource_state_error'
      autoload :ResourceRetrievalError, 'berta/errors/opennebula/resource_retrieval_error'
    end
  end
end
