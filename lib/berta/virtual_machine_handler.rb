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

    # Sets NOTIFIED value in USER_TEMPLATE to current time
    # as integer. After updating notified value
    # fetches data from opennebula database.
    #
    # @note This method modifies OpenNebula database
    # @raise [Berta::Errors::OpenNebula::AuthenticationError]
    # @raise [Berta::Errors::OpenNebula::UserNotAuthorizedError]
    # @raise [Berta::Errors::OpenNebula::ResourceNotFoundError]
    # @raise [Berta::Errors::OpenNebula::ResourceStateError]
    # @raise [Berta::Errors::OpenNebula::ResourceRetrievalError]
    def update_notified
      notify_time = Time.now
      logger.debug "Setting notified flag of VM with id #{handle['ID']} to #{notify_time}"
      return if Berta::Settings['dry-run']
      Berta::Utils::OpenNebula::Helper.handle_error do
        handle.update("#{NOTIFIED_FLAG} = #{notify_time.to_i}", true)
        handle.info
      end
    end

    # Return NOTIFIED value from USER_TEMPLATE if it is set
    # else nil.
    #
    # @return [Numeric] Time when notified was set else nil.
    #   Time is in UNIX epoch time format.
    def notified
      time = handle["USER_TEMPLATE/#{NOTIFIED_FLAG}"]
      time.to_i if time
    end

    # Determines if VM meets criteria to be notified.
    # To be notified, VM musn't be notified and
    # must have expiration with valid expiration
    # action in notification interval.
    #
    # @return [Boolean] If this vm should be notified.
    #   True if vm should be notified else false.
    def should_notify?
      return false if notified
      expiration = default_expiration
      return false unless expiration
      expiration.in_notification_interval?
    end

    # Adds schedule action to virtual machine. This command
    # modifies USER_TEMPLATE of virtual machine. But does
    # not delete old variables is USER_TEMPLATE.
    #
    # @note This method modifies OpenNebula database
    # @param time [Numeric] Time when to notify user
    # @param action [String] Action to perform on expiration
    def add_expiration(time, action)
      logger.debug "Setting expiration of VM with id #{handle['ID']} to #{action} on #{Time.at(time)} with id #{next_sched_action_id}"
      return if Berta::Settings['dry-run']
      new_expiration = \
        Berta::Entities::Expiration.new(next_sched_action_id,
                                        time,
                                        action)
      update_expirations(expirations << new_expiration)
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
      logger.debug "Setting multiple expirations:\n#{template}"
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

    private

    def next_sched_action_id
      elems = handle.retrieve_elements('USER_TEMPLATE/SCHED_ACTION/ID')
      return 0 unless elems
      elems.to_a.max.to_i + 1
    end
  end
end
