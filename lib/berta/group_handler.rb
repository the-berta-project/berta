module Berta
  # Class that handles all group Berta related operations
  class GroupHandler
    attr_reader :handle

    def initialize(group)
      @handle = group
      @email = handle['TEMPLATE/EMAIL']
      @name = handle['NAME']
    end

    def notify(group_vms)
      notification = Berta::Notification.new(@name, @email)
      to_notify = group_vms.keep_if(&:should_notify?)
      if to_notify.empty?
        logger.debug "No notifications for group #{@name}"
        return
      end
      notification.notify(to_notify)
      to_notify.each(&:update_notified)
    rescue Berta::Errors::Entities::NoEmailError
      logger.error "Group #{handle['ID']} has no email, skipping"
    end
  end
end
