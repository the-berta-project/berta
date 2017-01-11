module Berta
  # Class for Berta operations on virtual machines
  #
  # @author Dusan Baran
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
    end

    # @return [Numeric] Time when notified was set.
    #   Time is in UNIX epoch time format.
    def notified
      time = handle['USER_TEMPLATE/NOTIFIED']
      time.to_i if time
    end

    # Sets schelude action to virtual machine. This command
    #   modifies USER_TEMPLATE of virtual machine.
    #
    # @param [Numeric] Time when to notify user
    # @param [String] Action to perform on given time
    def update_expiration(time, action)
      template = <<-EOT
      SCHED_ACTION = [
          ACTION = "#{action}",
          TIME   = "#{time}"
      ]
      EOT
      Berta::Utils::OpenNebula::Helper.handle_error \
        { handle.update(template, true) }
    end

    # @return [Numeric] Time when expiration action will be
    #   executed. Time is in UNIX epoch time format.
    def expiration_time
      time = handle['USER_TEMPLATE/SCHED_ACTION/TIME']
      time.to_i if time
    end

    # Checks if expiration action was set
    #
    # @return [Boolean] True if expiration action was set, else False
    def expiration?
      expiration_time && expiration_action
    end

    # @return [String] Action that will execute on expiration
    def expiration_action
      handle['USER_TEMPLATE/SCHED_ACTION/ACTION']
    end
  end
end
