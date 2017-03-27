require 'opennebula'

module Berta
  # Berta service for communication with OpenNebula
  class Service
    attr_reader :endpoint
    attr_reader :client

    # Initializes service object and connects to opennebula
    # backend. If both arguments are nil default ONE_AUTH
    # will be used.
    #
    # @param secret [String] Opennebula secret
    # @param endpoint [String] Endpoint of OpenNebula
    def initialize(secret, endpoint)
      @endpoint = endpoint
      @client = OpenNebula::Client.new(secret, endpoint)
    end

    # Fetch running vms from OpenNebula and filter out vms that
    # take no resources.
    #
    # @return [Berta::VirtualMachineHandler] Virtual machines
    #   running on OpenNebula
    # @raise [Berta::Errors::OpenNebula::AuthenticationError]
    # @raise [Berta::Errors::OpenNebula::UserNotAuthorizedError]
    # @raise [Berta::Errors::OpenNebula::ResourceNotFoundError]
    # @raise [Berta::Errors::OpenNebula::ResourceStateError]
    # @raise [Berta::Errors::OpenNebula::ResourceRetrievalError]
    def running_vms
      vm_pool = OpenNebula::VirtualMachinePool.new(client)
      Berta::Utils::OpenNebula::Helper.handle_error { vm_pool.info_all }
      logger.debug "Fetched vms: #{vm_pool.map(&:id)}"
      Berta::Exclusions.new(Berta::Settings.exclude.ids,
                            Berta::Settings.exclude.users,
                            Berta::Settings.exclude.groups,
                            excluded_clusters).filter!(vm_pool.map { |vm| Berta::VirtualMachineHandler.new(vm) })
    end

    # Fetch users from OpenNebula
    #
    # @return [OpenNebula::UserPool] Users on OpenNebula
    # @raise [Berta::Errors::OpenNebula::AuthenticationError]
    # @raise [Berta::Errors::OpenNebula::UserNotAuthorizedError]
    # @raise [Berta::Errors::OpenNebula::ResourceNotFoundError]
    # @raise [Berta::Errors::OpenNebula::ResourceStateError]
    # @raise [Berta::Errors::OpenNebula::ResourceRetrievalError]
    def users
      user_pool = OpenNebula::UserPool.new(client)
      Berta::Utils::OpenNebula::Helper.handle_error { user_pool.info }
      logger.debug "Fetched users: #{user_pool.map(&:id)}"
      user_pool
    end

    # Fetch clusters from OpenNebula
    #
    # @return [OpenNebula::ClusterPool] Clusters on OpenNebula
    # @raise [Berta::Errors::OpenNebula::AuthenticationError]
    # @raise [Berta::Errors::OpenNebula::UserNotAuthorizedError]
    # @raise [Berta::Errors::OpenNebula::ResourceNotFoundError]
    # @raise [Berta::Errors::OpenNebula::ResourceStateError]
    # @raise [Berta::Errors::OpenNebula::ResourceRetrievalError]
    def clusters
      return @cached_clusters if @cached_clusters
      cluster_pool = OpenNebula::ClusterPool.new(client)
      Berta::Utils::OpenNebula::Helper.handle_error { cluster_pool.info }
      logger.debug "Fetched clusters: #{cluster_pool.map(&:id)}"
      @cached_clusters = cluster_pool
      cluster_pool
    end

    private

    def excluded_clusters
      excluded = []
      if Berta::Settings.exclude.clusters
        clusters.each do |cluster|
          excluded << cluster if Berta::Settings.exclude.clusters.find { |cname| cname == cluster['NAME'] }
        end
      end
      excluded
    end
  end
end
