require 'erb'
require 'tilt'

module Berta
  # Class for executing main berta commands
  class CommandExecutor
    def initialize
      email_file = 'email.erb'.freeze
      email_template_path = "#{File.dirname(__FILE__)}/../../config/#{email_file}"
      email_template_path = "/etc/berta/#{email_file}" \
        if File.exist?("/etc/berta/#{email_file}")
      email_template_path = "#{ENV['HOME']}/.berta/#{email_file}" \
        if File.exist?("#{ENV['HOME']}/.berta/#{email_file}")
      @email_template = Tilt.new(email_template_path)
    end

    # Function that performs clean up operation.
    # Connects to opennebula database,
    # runs expiration update process and
    # notifies users about upcoming expirations.
    def cleanup
      service = Berta::Service.new(Berta::Settings['opennebula']['secret'],
                                   Berta::Settings['opennebula']['endpoint'])
      vms = service.running_vms
      users = service.users
      vms.each(&:update)
      Mail.defaults { delivery_method :sendmail }
      users.each { |user| user.notify(service.user_vms(user), @email_template) }
    rescue Berta::Errors::BackendError => e
      logger.error e.message
    end
  end
end
