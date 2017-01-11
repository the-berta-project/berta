require 'settingslogic'

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
  end
end
