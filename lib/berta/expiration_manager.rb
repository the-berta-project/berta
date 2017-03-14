module Berta
  # Class for managing expiration dates on vms
  class ExpirationManager
    # Update all expirations on vm, removes invalid expirations
    # and if needed will set default expiration date.
    #
    # @param vms [Array<Berta::VirtualMachineHandler>] Virtual machines
    #   to update expiration on.
    def update_expirations(vms)
      vms.each do |vm|
        begin
          vm.update_expirations(add_default_expiration(vm, remove_invalid_expirations(vm.expirations)))
        rescue Berta::Errors::BackendError => e
          logger.error "#{e.message}\n\tOn vm with id #{vm.handle['ID']}"
        end
      end
    end

    # Removes invalid expirations from array of expirations.
    # Invalid expirations are expirations that are planned
    # later than expiration offset value.
    #
    # @param exps [Array<Berta::Entities::Expiration>] Expirations to filter
    # @return [Array<Berta::Entities::Expiration>] Filtered expirations
    def remove_invalid_expirations(exps)
      exps.keep_if(&:in_expiration_interval?)
    end

    # Adds default vm expiration into given array of expirations
    # assuming that array of expirations are expirations of given vm.
    # If vm already has default expiration nothing will be changed.
    #
    # @param vm [Berta::VirtualMachineHandler] VM with or without default expiration
    # @param exps [Array<Berta::Entities::Expiration>] VMs expirations to modify
    # @return Expirations with default expiration
    def add_default_expiration(vm, exps)
      return [] if vm.default_expiration
      exps << Berta::Entities::Expiration.new(vm.next_expiration_id,
                                              Time.now.to_i + Berta::Settings.expiration_offset,
                                              Berta::Settings.expiration.action)
    end
  end
end
