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

    def self.notification_deadline
      ChronicDuration.parse(self.get('notification.deadline'))
    end

    def self.expiration_offset
      ChronicDuration.parse(self.get('expiration.offset'))
    end
  end
end
