require 'opennebula'

module Berta
  # Berta service for communication with OpenNebula
  class Service
    attr_reader :endpoint
    attr_reader :client

    FILTERS = { 'exclude' => Berta::Utils::ExcludeFilter,
                'include' => Berta::Utils::IncludeFilter }.freeze

    # Initializes service object and connects to opennebula
    # backend. If both arguments are nil default ONE_AUTH
    # will be used.
    #
    # @param secret [String] Opennebula secret
    # @param endpoint [String] Endpoint of OpenNebula
    def initialize(secret, endpoint)
      @endpoint = endpoint
      @client = OpenNebula::Client.new(secret, endpoint)
      create_filter
    end

    def create_filter
      filter = FILTERS[Berta::Settings.filter.type]
      raise Berta::Errors::WrongFilterTypeError, "Wrong filter type: #{Berta::Settings.filter.type}" unless filter
      @filter = filter.new(Berta::Settings.filter.ids,
                           Berta::Settings.filter.users,
                           Berta::Settings.filter.groups,
                           filtered_clusters)
    end

    # Fetch running vms from OpenNebula and filter out vms that
    # take no resources.
    #
    # @return [Array<Berta::VirtualMachineHandler>] Virtual machines
    #   running on OpenNebula
    # @raise [Berta::Errors::OpenNebula::AuthenticationError]
    # @raise [Berta::Errors::OpenNebula::UserNotAuthorizedError]
    # @raise [Berta::Errors::OpenNebula::ResourceNotFoundError]
    # @raise [Berta::Errors::OpenNebula::ResourceStateError]
    # @raise [Berta::Errors::OpenNebula::ResourceRetrievalError]
    def running_vms
      return @cached_vms if @cached_vms
      vm_pool = OpenNebula::VirtualMachinePool.new(client)
      Berta::Utils::OpenNebula::Helper.handle_error { vm_pool.info_all_extended }
      logger.debug "Fetched vms: #{vm_pool.map(&:id)}"
      @cached_vms = @filter.run(vm_pool.map { |vm| Berta::VirtualMachineHandler.new(vm) })
      @cached_vms
    end

    # Fetch users from OpenNebula
    #
    # @return [Array<OpenNebula::UserHandler>] Users on OpenNebula
    # @raise [Berta::Errors::OpenNebula::AuthenticationError]
    # @raise [Berta::Errors::OpenNebula::UserNotAuthorizedError]
    # @raise [Berta::Errors::OpenNebula::ResourceNotFoundError]
    # @raise [Berta::Errors::OpenNebula::ResourceStateError]
    # @raise [Berta::Errors::OpenNebula::ResourceRetrievalError]
    def users
      user_pool = OpenNebula::UserPool.new(client)
      Berta::Utils::OpenNebula::Helper.handle_error { user_pool.info }
      logger.debug "Fetched users: #{user_pool.map(&:id)}"
      user_pool.map { |user| Berta::EntityHandler.new(user) }
    end

    def groups
      group_pool = OpenNebula::GroupPool.new(client)
      Berta::Utils::OpenNebula::Helper.handle_error { group_pool.info }
      logger.debug "Fetched groups: #{group_pool.map(&:id)}"
      group_pool.map { |group| Berta::EntityHandler.new(group) }
    end

    # Return vms that belong to given user
    #
    # @note calls running_vms
    # @param user [Berta::UserHandler] User to find vms for
    # @return [Array<Berta::VirtualMachineHandler>] VMs that belong to given user
    def user_vms(user)
      running_vms.select { |vm| vm.handle['UID'] == user.id }
    end

    def group_vms(group)
      running_vms.select { |vm| vm.handle['GID'] == group.id }
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

    def filtered_clusters
      return unless Berta::Settings.filter.clusters
      clusters.select { |cluster| Berta::Settings.filter.clusters.find { |cname| cname == cluster['NAME'] } }
    end
  end
end
