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
      @client = OpenNebula::Client.new(secret, endpoint)
    end

    # Fetch running vms from OpenNebula
    #
    # @return [Berta::VirtualMachineHandler] virtual machines
    #   running on OpenNebula
    # @raise [Berta::BackendError] if connection to OpenNebula failed
    def running_vms
      vm_pool = OpenNebula::VirtualMachinePool.new(client)
      Berta::Utils::OpenNebula::Helper.handle_error { vm_pool.info_all }
      vm_pool.map { |vm| Berta::VirtualMachineHandler.new(vm) }
             .keep_if { |vmh| whitelisted?(vmh) && running?(vmh) }
    end

    # Fetch users from OpenNebula
    #
    # @return [OpenNebula::UserPool] users on OpenNebula
    # @raise [Berta::BackendError] if connection failed
    def users
      user_pool = OpenNebula::UserPool.new(client)
      Berta::Utils::OpenNebula::Helper.handle_error { user_pool.info }
      user_pool
    end

    private

    def whitelisted?(vms)
    end

    def running?(vms)
    end
  end
end
