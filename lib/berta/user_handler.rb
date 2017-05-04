require 'mail'
require 'erb'
require 'tilt'

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
    end

    # Notifies user about all vms that are in notification interval
    #
    # @param user_vms [Array<Berta::VirtualMachineHandler>] All vms that belong to
    #   this user
    # @param email_template [Tilt::ERBTemplate] Email template
    def notify(user_vms, email_template)
      to_notify = user_vms.keep_if(&:should_notify?)
      return if to_notify.empty?
      send_notification(to_notify, email_template)
      user_vms.each(&:update_notified)
    rescue ArgumentError, Berta::Errors::Entities::NoUserEmailError => e
      logger.error e.message
    end

    def send_notification(user_vms, email_template)
      user_email = handle['TEMPLATE/EMAIL']
      user_name = handle['NAME']
      raise Berta::Errors::Entities::NoUserEmailError, "User: #{user_name} with id: #{handle['ID']} has no email set" \
        unless user_email
      email_text = email_template.render(Hash, user_email: user_email, user_name: user_name, vms: vms_data(user_vms))
      logger.debug "Sending mail to user: #{user_name} with email: #{user_email}:\n#{email_text}"
      Mail.new(email_text).deliver unless Berta::Settings['dry-run']
    end

    private

    def vms_data(vms)
      vms.map do |vm|
        { id: vm.handle['ID'],
          name: vm.handle['NAME'],
          expiration: vm.default_expiration.time.to_i }
      end
    end
  end
end
