require 'opennebula'

module Berta
  # Berta service for communication with OpenNebula
  class Service
    ACTIVE = 3

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
             .delete_if { |vmh| excluded?(vmh) || !running?(vmh) }
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

    def clusters
      cluster_pool = OpenNebula::ClusterPool.new(client)
      Berta::Utils::OpenNebula::Helper.handle_error { cluster_pool.info }
      cluster_pool
    end

    private

    def excluded?(vmh)
      excluded_id?(vmh) ||
        excluded_user?(vmh) ||
        excluded_group?(vmh) ||
        excluded_cluster?(vmh)
    end

    def excluded_id?(vmh)
      Berta::Settings.exclude.ids.find { |id| vmh.handle.id == id } \
        if vmh.handle.id && Berta::Settings.exclude.ids
    end

    def excluded_user?(vmh)
      Berta::Settings.exclude.users.find { |user| vmh.handle['UNAME'] == user } \
        if vmh.handle['UNAME'] && Berta::Settings.exclude.users
    end

    def excluded_group?(vmh)
      Berta::Settings.exclude.groups.find { |group| vmh.handle['GNAME'] == group } \
        if vmh.handle['GNAME'] && Berta::Settings.exclude.groups
    end

    def excluded_cluster?(vmh)
      return unless Berta::Settings.exclude.clusters
      vmcid = latest_cluster_id(vmh)
      vmcluster = clusters.find { |cluster| cluster['ID'] == vmcid }
      return unless vmcluster
      Berta::Settings.exclude.clusters.find { |name| vmcluster['NAME'] == name } \
        if vmcluster['NAME']
    end

    def latest_cluster_id(vmh)
      vmh.handle['HISTORY_RECORDS/HISTORY[last()]/CID']
    end

    def running?(vmh)
      vmh.handle.state == ACTIVE
    end
  end
end
