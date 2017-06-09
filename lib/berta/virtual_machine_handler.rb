module Berta
  # Class for Berta operations on virtual machines
  class VirtualMachineHandler
    NOTIFIED_FLAG = 'BERTA_NOTIFIED'.freeze

    attr_reader :handle

    # Constructs Virtual machine handler from given vm.
    #
    # @param vm [OpenNebula::VirtualMachine] VM that will
    #   this handler use.
    def initialize(vm)
      @handle = vm
    end

    # Updates vms expirations. That means it adds default
    # expiration if vm has no default expiration. If VM has
    # invalid expiration it will be deleted. Other expirations
    # are kept.
    def update
      exps = remove_invalid(expirations)
      exps = add_default_expiration(exps)
      return if exps == expirations
      update_expirations(exps)
    rescue Berta::Errors::BackendError => e
      logger.error "#{e.message} on vm with id #{handle['ID']}"
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
      logger.info "Setting notified flag of VM with id #{handle['ID']} to #{notify_time}"
      send_update("#{NOTIFIED_FLAG} = #{notify_time.to_i}")
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

    # Return notified flag value from USER_TEMPLATE if it is set
    # else nil.
    #
    # @return [Numeric] Time of expiration that VM was notified about
    def notified
      time = handle["USER_TEMPLATE/#{NOTIFIED_FLAG}"]
      time.to_i if time
    end

    def ==(other)
      handle.id == other.handle.id
    end

    private

    def remove_invalid(exps)
      valid = exps.select(&:in_expiration_interval?)
      if valid.length != exps.length
        logger.info "Removing #{exps.length - valid.length} invalid expirations on vm with" \
                    "id=#{handle['ID']} usr=#{handle['UNAME']} grp=#{handle['GNAME']}"
      end
      valid
    end

    def add_default_expiration(exps)
      unless default_expiration
        new_default = next_expiration
        exps << new_default
        logger.info "Adding default expiration on vm with id=#{handle['ID']} usr=#{handle['UNAME']} grp=#{handle['GNAME']}"\
          ", expires at #{Time.at(new_default.time)}"
      end
      exps
    end

    # Sets array of expirations to vm, rewrites all old ones.
    # Receiving empty array wont change anything.
    #
    # @note This method modifies OpenNebula database
    # @param exps [Array<Berta::Entities::Expiration>] Expirations to use
    def update_expirations(exps)
      template = exps.inject('') { |temp, exp| temp + exp.template }
      return if template == ''
      logger.debug template.delete("\n ")
      send_update(template)
    end

    # Sends data to opennebula service
    def send_update(template)
      return if Berta::Settings['dry-run']
      Berta::Utils::OpenNebula::Helper.handle_error do
        handle.update(template, true)
        handle.info
      end
    end

    # Return first available SCHED_ACTION/ID
    #
    # @return [Numeric] Next sched action id
    def next_expiration_id
      elems = handle.retrieve_elements('USER_TEMPLATE/SCHED_ACTION/ID')
      return 0 unless elems
      elems.to_a.max.to_i + 1
    end

    # Return default expiration that would be next for this vm
    #
    # @return [Berta::Entities::Expiration] Next expiration for this vm
    def next_expiration
      Berta::Entities::Expiration.new(next_expiration_id,
                                      Time.now.to_i + Berta::Settings.expiration_offset,
                                      Berta::Settings.expiration.action)
    end
  end
end
