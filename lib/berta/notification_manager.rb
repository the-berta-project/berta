require 'mail'
require 'erb'
require 'tilt'

module Berta
  # Class for managing notifications, setting and sending them
  class NotificationManager
    attr_reader :service, :email_template

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
    #   and sends email to each of them.
    #
    # @param [Array<VirtualMachineHandler>] Virtual machines
    #   to check for notifications.
    def notify_users(vms)
      users = service.users
      uids_to_notify(vms).each do |uid, uvms|
        user = users.find { |usr| usr['ID'] == uid }
        next unless user
        begin
          send_notification(user, uvms)
        rescue ArgumentError, Berta::Errors::Entities::NoUserEmailError => e
          puts e.message
          # log here
        else
          uvms.each(&:update_notified)
        end
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
      raise Berta::Errors::Entities::NoUserEmailError "User: #{user_name} has no email set" \
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
