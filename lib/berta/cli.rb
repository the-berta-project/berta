require 'thor'
require 'yell'

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
    class_option :'dry-run',
                 default: safe_fetch(%w(dry-run)),
                 type: :boolean
    class_option :'logging-file',
                 default: safe_fetch(%w(logging file)),
                 type: :string
    class_option :'logging-level',
                 required: true,
                 default: safe_fetch(%w(logging level)),
                 type: :string
    class_option :debug,
                 default: safe_fetch(%w(debug)),
                 type: :boolean

    desc 'cleanup', 'Task that sets all expiration to all vms and notifies users'
    def cleanup
      initialize_configuration(options)
      initialize_logger(options)
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
      settings['dry-run'] = options['dry-run']
      settings['debug'] = options['debug']
      settings['logging']['file'] = options['logging-file']
      settings['logging']['level'] = options['logging-level']
      Berta::Settings.merge!(settings)
    end

    def initialize_logger(options)
      logging_level = options['logging-level']
      logging_level = 'debug' if options['debug'] || options['dry-run']

      Yell.new :stdout, name: Object, level: logging_level, format: Yell::DefaultFormat
      Object.send :include, Yell::Loggable

      setup_file_logger(options['logging-file']) if options['logging-file']

      logger.debug 'Running in debug mode...'
    end

    def setup_file_logger(logging_file)
      unless (File.exist?(logging_file) && File.writable?(logging_file)) || File.writable?(File.dirname(logging_file))
        logger.error "File #{logging_file} isn't writable"
        return
      end
      logger.adapter :file, logging_file
    end
  end
end
