require 'erb'
require 'tilt'
require 'mail'

module Berta
  # Class that encapsulates mailing functionality
  class Notification
    email_file = 'email.erb'.freeze

    email_template_path = "#{File.dirname(__FILE__)}/../../config/#{email_file}"

    email_template_path = "/etc/berta/#{email_file}" \
      if File.exist?("/etc/berta/#{email_file}")

    email_template_path = "#{ENV['HOME']}/.berta/#{email_file}" \
      if File.exist?("#{ENV['HOME']}/.berta/#{email_file}")

    EMAIL_TEMPLATE = Tilt.new(email_template_path).freeze
    Mail.defaults { delivery_method :sendmail }

    def initialize(name, email)
      @name = name
      @email = email
      raise Berta::Errors::Entities::NoEmailError, 'Notification requires email' \
        unless @email
    end

    def notify(vms)
      text = EMAIL_TEMPLATE.render(Object.new, name: @name, email: @email, vms: vms_hash(vms))
      logger.info "Sending mail to entity: #{@name} on email: #{@email}"
      logger.debug text
      Mail.new(text).deliver unless Berta::Settings['dry-run']
    end

    def vms_hash(vms)
      vms.map do |vm|
        { id: vm.handle['ID'],
          name: vm.handle['NAME'],
          expiration: vm.default_expiration.time.to_i }
      end
    end
  end
end
