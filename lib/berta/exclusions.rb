module Berta
  # Class for Handeling berta exclusions
  class Exclusions
    # VM states that take resources
    RESOURCE_STATES = %w(SUSPENDED POWEROFF CLONING).freeze
    # Active state has some lcm states that should not expire
    ACTIVE_STATE = 'ACTIVE'.freeze
    # LCM states in which active state shouldn't expire
    NON_RESOURCE_ACTIVE_LCM_STATES = %w(EPILOG SHUTDOWN STOP UNDEPLOY FAILURE).freeze

    # Constructs Exclusions object.
    #
    # @param ids [Array<Numeric>] Ids of VM to exclude
    # @param users [Array<String>] User names to exclude
    # @param groups [Array<String>] Group names to exclude
    # @param clusters [Array<OpenNebula::Cluster>] Clusters to exclude
    def initialize(ids, users, groups, clusters)
      @ids = ids
      @users = users
      @groups = groups
      @clusters = clusters
      log_exclusions
    end

    # Filters out excluded vms, and vms that doesn't take resources
    #
    # @param vmhs [Array<Berta::VirtualMachineHandler>] Array of VMs to filter
    def filter!(vmhs)
      filter_resources!(vmhs)
      filter_ids!(vmhs)
      filter_users!(vmhs)
      filter_groups!(vmhs)
      filter_clusters!(vmhs)
      logger.debug "After excluding: #{vmhs.map { |vmh| vmh.handle.id }}"
      vmhs
    end

    private

    def log_exclusions
      logger.debug "Excluded ids     : #{@ids}"
      logger.debug "Excluded users   : #{@users}"
      logger.debug "Excluded groups  : #{@groups}"
      logger.debug "Excluded clusters: #{@clusters.map { |cluster| cluster['NAME'] }}"
    end

    def excluded_id?(vmh)
      @ids.find { |id| vmh.handle['ID'].to_i == id.to_i } if vmh.handle['ID'] && @ids
    end

    def excluded_user?(vmh)
      @users.find { |user| vmh.handle['UNAME'] == user } if vmh.handle['UNAME'] && @users
    end

    def excluded_group?(vmh)
      @groups.find { |group| vmh.handle['GNAME'] == group } if vmh.handle['GNAME'] && @groups
    end

    def excluded_cluster?(vmh)
      vmhcid = latest_cluster_id(vmh)
      @clusters.find { |cluster| vmhcid == cluster['ID'] } if vmhcid && @clusters
    end

    def takes_resources?(vmh)
      return true if RESOURCE_STATES.any? { |state| vmh.handle.state_str == state }
      true if vmh.handle.state_str == ACTIVE_STATE &&
              NON_RESOURCE_ACTIVE_LCM_STATES.none? { |state| vmh.handle.lcm_state_str.include? state }
    end

    def filter_ids!(vmhs)
      deleted, keep = vmhs.partition { |vmh| excluded_id?(vmh) }
      logger.debug "Excluding based on IDs. Excluded IDs            : #{deleted.map { |vmh| vmh.handle.id }}"
      vmhs.replace(keep)
      deleted
    end

    def filter_users!(vmhs)
      deleted, keep = vmhs.partition { |vmh| excluded_user?(vmh) }
      logger.debug "Excluding based on USERs. Excluded IDs          : #{deleted.map { |vmh| vmh.handle.id }}"
      vmhs.replace(keep)
      deleted
    end

    def filter_groups!(vmhs)
      deleted, keep = vmhs.partition { |vmh| excluded_group?(vmh) }
      logger.debug "Excluding based on GROUPs. Excluded IDs         : #{deleted.map { |vmh| vmh.handle.id }}"
      vmhs.replace(keep)
      deleted
    end

    def filter_clusters!(vmhs)
      deleted, keep = vmhs.partition { |vmh| excluded_cluster?(vmh) }
      logger.debug "Excluding based on CLUSTERs. Excluded IDs       : #{deleted.map { |vmh| vmh.handle.id }}"
      vmhs.replace(keep)
      deleted
    end

    def filter_resources!(vmhs)
      keep, deleted = vmhs.partition { |vmh| takes_resources?(vmh) }
      logger.debug "Excluding based on RESOURCE_STATEs. Excluded IDs: #{deleted.map { |vmh| vmh.handle.id }}"
      vmhs.replace(keep)
      deleted
    end

    def latest_cluster_id(vmh)
      vmh.handle['HISTORY_RECORDS/HISTORY[last()]/CID']
    end
  end
end
