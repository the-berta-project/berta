module Berta
  # Class for executing main berta commands
  class CommandExecutor
    def self.cleanup
      service = Berta::Service.new(Berta::Settings.opennebula.secret,
                                   Berta::Settings.opennebula.endpoint)
      vms = service.running_vms
      Berta::ExpirationManager.new.update_expirations(vms)
      Berta::NotificationManager.new(service).notify_users(vms)
    end
  end
end
