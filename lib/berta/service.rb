require 'opennebula'

module Berta
  class Service
    def initialize(endpoint = 'http://147.251.17.221:2633/RPC2')
      @endpoint = endpoint
      @client = OpenNebula::Client.new('oneadmin:opennebula', @endpoint)
    end

    def running_vms
      vm_pool = OpenNebula::VirtualMachinePool.new(@client) 
      raise Berta::BackendError, 'Failed to fetch vms' \
        unless vm_pool.info_all == nil
			vm_pool
    end
    
    def set_expiration_date(date, vm)
    end

    def set_notified(vm)
      raise Berta::BackendError, 'Failed to set notified to vm' unless vm.update("NOTIFIED = #{Time.now.to_i}", true) == nil
    end
  end
end
