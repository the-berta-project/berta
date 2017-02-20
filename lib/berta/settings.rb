require 'settingslogic'
require 'chronic_duration'

module Berta
  # Class for storing setting for Berta
  class Settings < Settingslogic
    CONFIGURATION = 'berta.yml'.freeze

    source "#{ENV['HOME']}/.berta/#{CONFIGURATION}"\
    if File.exist?("#{ENV['HOME']}/.berta/#{CONFIGURATION}")

    source "/etc/berta/#{CONFIGURATION}"\
    if File.exist?("/etc/berta/#{CONFIGURATION}")

    source "#{File.dirname(__FILE__)}/../../config/#{CONFIGURATION}"

    namespace 'berta'

    # Notification deadline can be written in settings file in human
    # readable form. This function will return notification deadline
    # value as integer.
    #
    # @return [Numeric] Notification deadline
    def self.notification_deadline
      ChronicDuration.parse(get('notification.deadline'))
    end

    # Expiration offset can be written in settings file in human
    # readable form. This function will return expiration offset
    # value as integer.
    #
    # @return [Numeric] Expiration offset
    def self.expiration_offset
      ChronicDuration.parse(get('expiration.offset'))
    end
  end
end
