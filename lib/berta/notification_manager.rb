require 'mail'
require 'erb'
require 'tilt'

module Berta
  # Class for managing notifications, setting and sending them
  class NotificationManager
    EMAIL_TEMPLATE = 'email.erb'.freeze

    def initialize(service)
      @service = service
      @email_template_path = "#{File.dirname(__FILE__)}/../../config/#{EMAIL_TEMPLATE}"
      @email_template_path = "etc/berta/#{EMAIL_TEMPLATE}" \
        if File.exist?("etc/berta/#{EMAIL_TEMPLATE}")
      @email_template_path = "#{ENV['HOME']}/.berta/#{EMAIL_TEMPLATE}" \
        if File.exist?("#{ENV['HOME']}/.berta/#{EMAIL_TEMPLATE}")
      @email_template = Tilt.new(@email_template_path)
    end

    # Notifies users. Finds all users that should be notified
    #   and sends email to each of them.
    #
    # @param [Array<VirtualMachineHandler>] Virtual machines
    #   to check for notifications.
    def notify_users(vms)
      users = @service.users
      uids_to_notify(vms).each do |uid, uvms|
        user = users.find { |usr| usr['ID'] == uid }
        send_notification(user, uvms)
      end
    end

    # @param [Array<VirtualMachineHandler>]
    # @return [Hash<String, Array<VirtualMachineHandler>>]
    def uids_to_notify(vms)
      notif = vms.keep_if(&:should_notify?)
      uidsvm = Hash.new([])
      notif.each { |vm| uidsvm[vm.handle['UID']] += [vm] }
      uidsvm
    end

    # Sends email to given user about given vms and sets notified
    #   to all given vms.
    #
    # @param [OpenNebula::User] user to notify
    # @param [Array<VirtualMachineHandler>] vms to notify about
    def send_notification(user, vms)
      user_email = user['TEMPLATE/EMAIL']
      user_name = user['NAME']
      return nil unless user_email
      email_body = @email_template.render(Hash, user_name: user_name, vms: vms)
      Mail.deliver do
        from Berta::Settings.email.from
        to user_email
        subject Berta::Settings.email.subject
        body email_body
      end
      vms.each(&:update_notified)
    end
  end
end
