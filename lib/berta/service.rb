require 'opennebula'

module Berta
  class Service
    def initialize(endpoint = 'http://147.251.17.221:2633/RPC2')
      @endpoint = endpoint
      @client = OpenNebula::Client.new('oneadmin:opennebula', @endpoint)
    end

    def running_vms
      vm_pool = OpenNebula::VirtualMachinePool.new(@client) 
      vm_pool.info_all
			vm_pool
    end
  end
end
