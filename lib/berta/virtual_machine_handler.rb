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
    def add_expiration(time, action)
      template = <<-EOT
      SCHED_ACTION = [
          ID     = "#{max_sched_action_id}"
          ACTION = "#{action}",
          TIME   = "#{time}"
      ]
      EOT
      Berta::Utils::OpenNebula::Helper.handle_error \
        { handle.update(template, true) }
    end

    def expirations
      handle.to_hash['VM']['USER_TEMPLATE']['SCHED_ACTION'].map do |sah|
        Berta::Entities::Expiration.from_hash(sah)
      end
    end

  private

    def max_sched_action_id
      handle.retrieve_elements('USER_TEMPLATE/SCHED_ACTION/ID').to_a.max.to_i
    end
  end
end
