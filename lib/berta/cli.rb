require 'thor'

module Berta
  # CLI for berta
  class CLI < Thor
    def self.safe_fetch(keys)
      current = Berta::Settings
      keys.each do |key|
        current = current[key]
        break unless current
      end
      current
    end

    class_option :'opennebula-secret',
                 default: safe_fetch(%w(opennebula secret)),
                 type: :string
    class_option :'opennebula-endpoint',
                 default: safe_fetch(%w(opennebula endpoint)),
                 type: :string
    class_option :'expiration-offset',
                 required: true,
                 default: safe_fetch(%w(expiration offset)),
                 type: :string
    class_option :'expiration-action',
                 required: true,
                 default: safe_fetch(%w(expiration action)),
                 type: :string
    class_option :'notification-deadline',
                 required: true,
                 default: safe_fetch(%w(notification deadline)),
                 type: :string
    class_option :'exclude-ids',
                 default: safe_fetch(%w(exclude ids)),
                 type: :array
    class_option :'exclude-users',
                 default: safe_fetch(%w(exclude users)),
                 type: :array
    class_option :'exclude-groups',
                 default: safe_fetch(%w(exclude groups)),
                 type: :array
    class_option :'exclude-clusters',
                 default: safe_fetch(%w(exclude clusters)),
                 type: :array

    desc 'cleanup', 'Task that sets all expiration to all vms and notifies users'
    def cleanup
      initialize_configuration(options)
      Berta::CommandExecutor.cleanup
    end
    default_task :cleanup

    private

    def initialize_configuration(options)
      settings = Hash.new { |hash, key| hash[key] = {} }
      settings['opennebula']['secret'] = options['opennebula-secret']
      settings['opennebula']['endpoint'] = options['opennebula-endpoint']
      settings['expiration']['offset'] = options['expiration-offset']
      settings['expiration']['action'] = options['expiration-action']
      settings['notification']['deadline'] = options['notification-deadline']
      settings['exclude']['ids'] = options['exclude-ids']
      settings['exclude']['users'] = options['exclude-users']
      settings['exclude']['groups'] = options['exclude-groups']
      settings['exclude']['clusters'] = options['exclude-clusters']
      Berta::Settings.merge!(settings)
    end
  end
end
