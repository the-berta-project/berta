require 'opennebula'

module Berta
  module Utils
    module OpenNebula
      # Class designed to help with working with OpenNebula
      class Helper
        class << self
          ERRORS = Hash.new(Berta::Errors::OpenNebula::ResourceRetrievalError)
                       .update(::OpenNebula::Error::EAUTHENTICATION => Berta::Errors::OpenNebula::AuthenticationError,
                               ::OpenNebula::Error::EAUTHORIZATION => Berta::Errors::OpenNebula::UserNotAuthorizedError,
                               ::OpenNebula::Error::ENO_EXISTS => Berta::Errors::OpenNebula::ResourceNotFoundError,
                               ::OpenNebula::Error::EACTION => Berta::Errors::OpenNebula::ResourceStateError)
                       .freeze
          # Handles OpenNebula error codes and turns them into exceptions
          #
          # @raise [Berta::Errors::OpenNebula::AuthenticationError]
          # @raise [Berta::Errors::OpenNebula::UserNotAuthorizedError]
          # @raise [Berta::Errors::OpenNebula::ResourceNotFoundError]
          # @raise [Berta::Errors::OpenNebula::ResourceStateError]
          # @raise [Berta::Errors::OpenNebula::ResourceRetrievalError]
          def handle_error
            unless block_given?
              raise Berta::Errors::OpenNebula::StubError, 'OpenNebula service-wrapper was called without a block!'
            end
            return_value = yield
            return return_value unless ::OpenNebula.is_error?(return_value)
            raise decode_error(return_value.errno), return_value.message
          end

          # Decodes OpenNebula error codes into exceptions and returns them
          #
          # @param [OpenNebula::Error] error code to turn into exception
          # @return [Berta::Errors::OpenNebula::AuthenticationError]
          # @return [Berta::Errors::OpenNebula::UserNotAuthorizedError]
          # @return [Berta::Errors::OpenNebula::ResourceNotFoundError]
          # @return [Berta::Errors::OpenNebula::ResourceStateError]
          # @return [Berta::Errors::OpenNebula::ResourceRetrievalError]
          def decode_error(errno)
            ERRORS[errno]
          end
        end
      end
    end
  end
end
