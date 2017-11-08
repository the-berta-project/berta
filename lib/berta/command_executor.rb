module Berta
  # Class for executing main berta commands
  class CommandExecutor
    # Function that performs clean up operation.
    # Connects to opennebula database,
    # runs expiration update process and
    # notifies users about upcoming expirations.
    def cleanup
      service = Berta::Service.new(Berta::Settings['opennebula']['secret'],
                                   Berta::Settings['opennebula']['endpoint'])
      vms = service.running_vms
      users = service.users
      groups = service.groups
      vms.each(&:update)
      users.each { |user| user.notify(service.user_vms(user)) }
      groups.each { |group| group.notify(service.group_vms(group)) }
    rescue Berta::Errors::BackendError => e
      logger.error e.message
    end
  end
end
