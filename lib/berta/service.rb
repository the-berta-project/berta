require 'opennebula'

module Berta
  # Berta service for communication with OpenNebula
  class Service
    attr_reader :endpoint
    attr_reader :client

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
    # @return [Berta::VirtualMachineHandler] virtual machines
    #   running on OpenNebula
    # @raise [Berta::BackendError] if connection to OpenNebula failed
    def running_vms
      vm_pool = OpenNebula::VirtualMachinePool.new(@client)
      Berta::Utils::OpenNebula::Helper.handle_error { vm_pool.info_all }
      vm_pool.map { |vm| Berta::VirtualMachineHandler.new(vm) }
    end
  end
end
