module Berta
  # Class for Berta operations on virtual machines
  class VirtualMachineHandler
    NOTIFIED_FLAG = 'BERTA_NOTIFIED'.freeze

    attr_reader :handle

    # Constructs Virtual machine handler from given vm.
    #
    # @param vm [Berta::VirtualMachineHandler] VM that will
    #   this handler use.
    def initialize(vm)
      @handle = vm
    end

    # Sets notified flag value in USER_TEMPLATE to default expiration
    # time as integer. If VM has no default expiration nothing will
    # be updated. After updating notified value
    # fetches data from opennebula database.
    #
    # @note This method modifies OpenNebula database
    # @raise [Berta::Errors::OpenNebula::AuthenticationError]
    # @raise [Berta::Errors::OpenNebula::UserNotAuthorizedError]
    # @raise [Berta::Errors::OpenNebula::ResourceNotFoundError]
    # @raise [Berta::Errors::OpenNebula::ResourceStateError]
    # @raise [Berta::Errors::OpenNebula::ResourceRetrievalError]
    def update_notified
      exp = default_expiration
      return unless exp
      notify_time = exp.time
      logger.debug "Setting notified flag of VM with id #{handle['ID']} to #{notify_time}"
      return if Berta::Settings['dry-run']
      Berta::Utils::OpenNebula::Helper.handle_error do
        handle.update("#{NOTIFIED_FLAG} = #{notify_time.to_i}", true)
        handle.info
      end
    end

    # Return notified flag value from USER_TEMPLATE if it is set
    # else nil.
    #
    # @return [Numeric] Time of expiration that VM was notified about
    def notified
      time = handle["USER_TEMPLATE/#{NOTIFIED_FLAG}"]
      time.to_i if time
    end

    # Determines if VM meets criteria to be notified.
    # To be notified, VM musn't have the same notification
    # time as default expiration time and must be in
    # notification interval.
    #
    # @return [Boolean] If this vm should be notified.
    #   True if vm should be notified else false.
    def should_notify?
      expiration = default_expiration
      return false unless expiration
      return false if notified == expiration.time.to_i
      expiration.in_notification_interval?
    end

    # Sets array of expirations to vm, rewrites all old ones.
    # Receiving empty array wont change anything.
    #
    # @note This method modifies OpenNebula database
    # @param exps [Array<Berta::Entities::Expiration>] Expirations to use
    def update_expirations(exps)
      template = ''
      exps.each { |exp| template += exp.template }
      return if template == ''
      logger.debug \
        "Setting expirations on vm with id=#{handle['ID']} usr=#{handle['UNAME']} grp=#{handle['GNAME']} : #{template.delete("\n ")}"
      return if Berta::Settings['dry-run']
      Berta::Utils::OpenNebula::Helper.handle_error do
        handle.update(template, true)
        handle.info
      end
    end

    # Returns array of expirations on vm. Expirations are
    # classes from USER_TEMPLATE/SCHED_ACTION.
    #
    # @return [Array<Berta::Entities::Expiration>] All expirations on vm
    def expirations
      exps = []
      handle.each('USER_TEMPLATE/SCHED_ACTION') \
        { |saxml| exps.push(Berta::Entities::Expiration.from_xml(saxml)) }
      exps
    end

    # Return default expiration, that means expiration with
    # default expiration action that is in expiration offset interval
    # and is closes to current date.
    #
    # @return [Berta::Entities::Expiration] Nearest default expiration else nil
    def default_expiration
      expirations
        .find_all { |exp| exp.default_action? && exp.in_expiration_interval? }
        .min { |exp| exp.time.to_i }
    end

    # Return first available SCHED_ACTION/ID
    #
    # @return [Numeric] Next sched action id
    def next_expiration_id
      elems = handle.retrieve_elements('USER_TEMPLATE/SCHED_ACTION/ID')
      return 0 unless elems
      elems.to_a.max.to_i + 1
    end
  end
end
