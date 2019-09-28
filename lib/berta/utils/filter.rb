module Berta
  module Utils
    # Base Filter class, filters out invalid states
    class Filter
      # VM states to ignore
      IGNORED_STATES = %w[PENDING HOLD].freeze

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

        locked_vmhs, fvmhs = fvmhs.partition { |vmh| is_locked?(vmh) }
        logger.debug "Filtered based on LOCK: #{locked_vmhs.map { |vmh| vmh.handle.id }}"

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
        !IGNORED_STATES.include?(vmh.handle.state_str)
      end

      def is_locked?(vmh)
        vmh.handle['LOCK/LOCKED'] && vmh.handle['LOCK/LOCKED'] != '0'
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
