module Berta
  # Class for handeling user methods
  class UserHandler
    attr_reader :handle

    # Initializes UserHandler object
    #
    # @param user [OpenNebula::User] User that will this
    #   handle use
    def initialize(user)
      @handle = user
      @email = handle['TEMPLATE/EMAIL']
      @name = handle['NAME']
    end

    def notify(vms)
      notification = Berta::Notification.new(@name, @email)
      to_notify = vms.keep_if(&:should_notify?)
      if to_notify.empty?
        logger.debug "No notifications for user #{@name}"
        return
      end
      notification.notify(to_notify)
      to_notify.each(&:update_notified)
    rescue Berta::Errors::Entities::NoEmailError
      logger.error "User #{handle['ID']} has no email, skipping"
    end
  end
end
