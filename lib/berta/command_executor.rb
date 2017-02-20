module Berta
  # Class for executing main berta commands
  class CommandExecutor
    # Function that performs clean up operation.
    # Connects to opennebula database,
    # runs expiration update process and
    # notifies users about upcoming expirations.
    def self.cleanup
      service = Berta::Service.new(Berta::Settings['opennebula']['secret'],
                                   Berta::Settings['opennebula']['endpoint'])
      vms = service.running_vms
      Berta::ExpirationManager.new.update_expirations(vms)
      Berta::NotificationManager.new(service).notify_users(vms)
    rescue Berta::Errors::BackendError => e
      logger.error e.message
    end
  end
end
