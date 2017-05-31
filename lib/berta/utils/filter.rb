module Berta
  module Utils
    # Base Filter class, filters out invalid states
    class Filter
      # VM states that take resources
      RESOURCE_STATES = %w[SUSPENDED POWEROFF CLONING].freeze
      # Active state has some lcm states that should not expire
      ACTIVE_STATE = 'ACTIVE'.freeze
      # LCM states in which active state shouldn't expire
      NON_RESOURCE_ACTIVE_LCM_STATES = %w[EPILOG SHUTDOWN STOP UNDEPLOY FAILURE].freeze

      # Constructs Filter object.
      #
      # @param ids [Array<Numeric>] Ids of VM to filter
      # @param users [Array<String>] User names to filter
      # @param groups [Array<String>] Group names to filter
      # @param clusters [Array<OpenNebula::Cluster>] Clusters to filter
      def initialize(ids, users, groups, clusters)
        @ids = ids || []
        @users = users || []
        @groups = groups || []
        @clusters = clusters || []
        logger.debug "Filter type: #{self.class}"
        log_filter
      end

      # Execute this filter
      #
      # @param vmhs [Array<Berta::VirtualMachineHandler>] VMs to filter
      # @return [Array<Berta::VirtualMachineHandler>] Filtered VMs
      def run(vmhs)
        fvmhs = vmhs.select { |vmh| takes_resources?(vmh) }
        logger.debug "Filtered based on RESOURCE: #{(vmhs - fvmhs).map { |vmh| vmh.handle.id }}"
        fvmhs = filter(fvmhs)
        logger.debug "VMS after filter : #{fvmhs.map { |vmh| vmh.handle.id }}"
        fvmhs
      end

      protected

      # This method is for child classes to override.
      # It is executed in `run` method.
      #
      # @param vmhs [Array<Berta::VirtualMachineHandler>] VMs without invalid states
      # @return [Array<Berta::VirtualMachineHandler>] Filtered VMs
      def filter(vmhs)
        vmhs
      end

      # Gets latest cluster id on given VM
      #
      # @param vmh [Berta::VirtualMachineHandler] VM to get cluster id on
      # @return [String] Latest cluster id
      def latest_cluster_id(vmh)
        vmh.handle['HISTORY_RECORDS/HISTORY[last()]/CID']
      end

      def filter_ids(vmhs)
        idi = vmhs.select { |vmh| @ids.include?(vmh.handle['ID']) }
        logger.debug "[#{self.class}] filtered based on IDs: #{idi.map { |vmh| vmh.handle.id }}"
        idi
      end

      def filter_users(vmhs)
        useri = vmhs.select { |vmh| @users.include?(vmh.handle['UNAME']) }
        logger.debug "[#{self.class}] filtered based on USERs: #{useri.map { |vmh| vmh.handle.id }}"
        useri
      end

      def filter_groups(vmhs)
        groupi = vmhs.select { |vmh| @groups.include?(vmh.handle['GNAME']) }
        logger.debug "[#{self.class}] filtered based on GROUPs: #{groupi.map { |vmh| vmh.handle.id }}"
        groupi
      end

      def filter_clusters(vmhs)
        cids = @clusters.map { |cluster| cluster['ID'] }
        clusteri = vmhs.select { |vmh| cids.include?(latest_cluster_id(vmh)) }
        logger.debug "[#{self.class}] filtered based on CLUSTERs: #{clusteri.map { |vmh| vmh.handle.id }}"
        clusteri
      end

      private

      def takes_resources?(vmh)
        return true if RESOURCE_STATES.any? { |state| vmh.handle.state_str == state }
        true if vmh.handle.state_str == ACTIVE_STATE &&
                NON_RESOURCE_ACTIVE_LCM_STATES.none? { |state| vmh.handle.lcm_state_str.include? state }
      end

      def log_filter
        logger.debug "Filter ids     : #{@ids}"
        logger.debug "Filter users   : #{@users}"
        logger.debug "Filter groups  : #{@groups}"
        logger.debug "Filter clusters: #{@clusters.map { |cluster| cluster['NAME'] }}"
      end
    end
  end
end
