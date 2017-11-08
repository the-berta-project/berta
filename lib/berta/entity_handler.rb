module Berta
  # Class for handeling entities in OpenNebula
  class EntityHandler
    attr_reader :type, :name, :email, :id, :handle

    def initialize(handle)
      @handle = handle
      @type = handle.class.name.split('::').last
      @name = handle['NAME']
      @email = handle['TEMPLATE/EMAIL']
      @id = handle['ID']
    end

    def notify(vms)
      notification = Berta::Notification.new(name, email)
      to_notify = vms.keep_if(&:should_notify?)
      if to_notify.empty?
        logger.debug { "No notifications for #{type} #{name} with id #{id}" }
        return
      end
      notification.notify(to_notify)
      to_notify.each(&:update_notified)
    rescue Berta::Errors::Entities::NoEmailError
      logger.debug { "#{type} #{id} has no email, skipping" }
    end
  end
end
