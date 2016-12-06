module Berta
  # Module for Netjockey error classes
  module Errors
    autoload :StandardError, 'netjockey/errors/standard_error'
    autoload :BackendError, 'netjockey/errors/backend_error'
  end
end
