# Main Berta module
module Berta
  autoload :Version, 'berta/version'
  autoload :Service, 'berta/service'
  autoload :VirtualMachineHandler, 'berta/virtual_machine_handler'
  autoload :ExpirationManager, 'berta/expiration_manager'
  autoload :NotificationManager, 'berta/notification_manager'
  autoload :CommandExecutor, 'berta/command_executor'
  autoload :CLI, 'berta/cli'
  autoload :Errors, 'berta/errors'
  autoload :Entities, 'berta/entities'
  autoload :Utils, 'berta/utils'
  autoload :Settings, 'berta/settings'
end
