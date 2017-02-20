require 'mail'
require 'erb'
require 'tilt'

module Berta
  # Class for managing notifications, setting and sending them
  class NotificationManager
    attr_reader :service, :email_template

    # Creates NotificationManager object with given service.
    # Notification manager needs service for fetching user
    # data from opennebula database. Also initializes
    # email template object.
    #
    # @param service [Berta::Service] Service that will be used
    #   for fetching data.
    def initialize(service)
      @service = service
      email_file = 'email.erb'.freeze
      email_template_path = "#{File.dirname(__FILE__)}/../../config/#{email_file}"
      email_template_path = "etc/berta/#{email_file}" \
        if File.exist?("etc/berta/#{email_file}")
      email_template_path = "#{ENV['HOME']}/.berta/#{email_file}" \
        if File.exist?("#{ENV['HOME']}/.berta/#{email_file}")
      @email_template = Tilt.new(email_template_path)
    end

    # Notifies users. Finds all users that should be notified
    # and sends email to each of them. Email is generated
    # from template.
    #
    # @param vms [Array<Berta::VirtualMachineHandler>] Virtual machines
    #   to check for notifications.
    def notify_users(vms)
      begin
        users = service.users
      rescue Berta::Errors::BackendError => e
        logger.error e.message
        return
      end
      uids_to_notify(vms).each do |uid, uvms|
        user = users.find { |usr| usr['ID'] == uid }
        notify_user(user, uvms) if user
      end
    end

    # Notifies given user about given vms.
    #
    # @param user [OpenNebula::User] User to notify
    # @param user_vms [Array<Berta::VirtualMachineHandler>] VMs to notify about
    def notify_user(user, user_vms)
      send_notification(user, user_vms)
    rescue ArgumentError, Berta::Errors::Entities::NoUserEmailError => e
      logger.error e.message
    else
      user_vms.each(&:update_notified)
    end

    # Finds and return uids of users from vms that should be notified.
    #
    # @param vms [Array<VirtualMachineHandler>] VMs to check for notification
    # @return [Hash<String, Array<VirtualMachineHandler>>] Hash of user ids to
    #   vms that user with key id should be notified about
    def uids_to_notify(vms)
      notif = vms.keep_if(&:should_notify?)
      uidsvm = Hash.new([])
      notif.each { |vm| uidsvm[vm.handle['UID']] += [vm] }
      uidsvm
    end

    # Sends email to given user about given vms using sendmail. Email
    # is generated from email template.
    #
    # @param user [OpenNebula::User] User to notify
    # @param vms [Array<Berta::VirtualMachineHandler>] VMs to notify user about
    # @raise [Berta::Errors::Entities::NoUserEmailError] If user has no email set
    def send_notification(user, vms)
      user_email = user['TEMPLATE/EMAIL']
      user_name = user['NAME']
      raise Berta::Errors::Entities::NoUserEmailError, "User: #{user_name} with id: #{user['ID']} has no email set" \
        unless user_email
      mail = Mail.new(email_template.render(Hash,
                                            user_email: user_email,
                                            user_name: user_name,
                                            vms: vms_data(vms)))
      mail.delivery_method :sendmail
      mail.deliver
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
