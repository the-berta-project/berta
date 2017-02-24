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

    # TODO
    def remove_invalid_expirations(exps)
      exps.keep_if(&:in_expiration_interval?)
    end

    # TODO
    def add_default_expiration(vm, exps)
      return exps if vm.default_expiration
      exps << Berta::Entities::Expiration.new(vm.next_expiration_id,
                                              Time.now.to_i + Berta::Settings.expiration_offset,
                                              Berta::Settings.expiration.action)
    end
  end
end
