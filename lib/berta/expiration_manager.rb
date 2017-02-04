module Berta
  # Class for managing expiration dates on vms
  class ExpirationManager
    # Update all expirations on vm, removes invalid expirations
    #   and if needed will set default expiration date
    #
    # @param [Array<VirtualMachineHandler>] virtual machines
    #   to update expiration on
    def update_expirations(vms)
      vms.each do |vm|
        remove_invalid_expirations(vm)
        add_default_expiration(vm)
      end
    end

    # Removes invalid expirations on vm
    #
    # @param [VirtualMachineHandler] vm
    def remove_invalid_expirations(vm)
      exps = vm.expirations
      exps.keep_if(&:in_expiration_interval?)
      vm.update_expirations(exps) if exps.length != vm.expirations.length
    rescue Berta::Errors::BackendError => e
      logger.error "#{e.message}\n\tOn vm with id #{vm.handle['ID']}"
    end

    # Adds default expiration if no expiration with
    #   right expiration action is set
    #
    # @param [VirtualMachineHandler] vm
    def add_default_expiration(vm)
      return if vm.default_expiration
      vm.add_expiration(Time.now.to_i + Berta::Settings.expiration_offset,
                        Berta::Settings.expiration.action)
    rescue Berta::Errors::BackendError => e
      logger.error "#{e.message}\n\tOn vm with id #{vm.handle['ID']}"
    end
  end
end
