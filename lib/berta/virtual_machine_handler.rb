module Berta
  # Class for Berta operations on virtual machines
  class VirtualMachineHandler
    attr_reader :handle

    def initialize(vm)
      @handle = vm
    end

    # Sets notified into USER_TEMPLATE on virtual machine
    #
    # @note This method modifies OpenNebula database
    # @raise [BackendError] if connection to service failed
    def update_notified
      Berta::Utils::OpenNebula::Helper.handle_error \
        { handle.update("NOTIFIED = #{Time.now.to_i}", true) }
      handle.info
    end

    # @return [Numeric] Time when notified was set.
    #   Time is in UNIX epoch time format.
    def notified
      time = handle['USER_TEMPLATE/NOTIFIED']
      time.to_i if time
    end

    # Adds schelude action to virtual machine. This command
    #   modifies USER_TEMPLATE of virtual machine. But does
    #   not delete old variables is USER_TEMPLATE.
    #
    # @param [Numeric] Time when to notify user
    # @param [String] Action to perform on given time
    def add_expiration(time, action)
      template = \
        Berta::Entities::Expiration.new(next_sched_action_id,
                                        time,
                                        action).template
      expirations.each { |exp| template += exp.template }
      Berta::Utils::OpenNebula::Helper.handle_error \
        { handle.update(template, true) }
      handle.info
    end

    # Sets array of expirations to vm, rewrites all old ones
    #
    # @param [Array<Expiration>] Expirations to use
    def update_expirations(exps)
      template = ''
      exps.each { |exp| template += exp.template }
      Berta::Utils::OpenNebula::Helper.handle_error \
        { handle.update(template, true) }
      handle.info
    end

    # Returns array of expirations on vm
    #
    # @return [Array<Expiration>] All expirations on vm
    def expirations
      exps = []
      handle.each('USER_TEMPLATE/SCHED_ACTION') \
        { |saxml| exps.push(Berta::Entities::Expiration.from_xml(saxml)) }
      exps
    end

    private

    def next_sched_action_id
      elems = handle.retrieve_elements('USER_TEMPLATE/SCHED_ACTION/ID')
      return 0 unless elems
      elems.to_a.max.to_i + 1
    end
  end
end
