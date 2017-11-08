require 'erb'
require 'tilt'
require 'mail'

module Berta
  # Class that encapsulates mailing functionality
  class Notification
    attr_accessor :name, :email, :template

    def initialize(name, email)
      @name = name
      @email = email
      @template = Tilt.new(Berta::Settings['email-template'])
      raise Berta::Errors::Entities::NoEmailError, 'Notification requires email' \
        unless email
    end

    def notify(vms)
      text = template.render(Object.new, name: name, email: email, vms: vms_hash(vms))
      logger.info "Sending mail to entity: #{name} on email: #{email}"
      logger.debug { text }
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
