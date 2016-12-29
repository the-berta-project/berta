require 'opennebula'

module Berta
  # Berta service for communication with OpenNebula
  class Service
    # Initializes service object
    #
    # @param secret [String] opennebula secret
    # @param endpoint [String] endpoint of OpenNebula
    def initialize(secret, endpoint)
      @endpoint = endpoint
      @client = OpenNebula::Client.new(secret, @endpoint)
    end

    # Fetch running vms from OpenNebula
    #
    # @return [OpenNebula::VirtualMachinePool] virtual machines
    #   running on OpenNebula
    # @raise [Berta::BackendError] if connection to OpenNebula failed
    def running_vms
      vm_pool = OpenNebula::VirtualMachinePool.new(@client)
      raise Berta::BackendError, 'Failed to fetch vms' \
        unless vm_pool.info_all.nil?
      vm_pool
    end
  end
end
