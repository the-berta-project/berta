require 'thor'

module Berta
  # CLI for berta
  class CLI < Thor
    class_option :'opennebula-secret',
                 required: true,
                 default: Berta::Settings['opennebula']['secret'],
                 type: :string
    class_option :'opennebula-endpoint',
                 required: true,
                 default: Berta::Settings['opennebula']['endpoint'],
                 type: :string
    class_option :'expiration-offset',
                 required: true,
                 default: Berta::Settings['expiration']['offset'],
                 type: :string
    class_option :'expiration-action',
                 required: true,
                 default: Berta::Settings['expiration']['action'],
                 type: :string
    class_option :'notification-deadline',
                 required: true,
                 default: Berta::Settings['notification']['deadline'],
                 type: :string
    class_option :'exclude-ids',
                 required: false,
                 default: Berta::Settings['exclude']['ids'],
                 type: :array
    class_option :'exclude-users',
                 required: false,
                 default: Berta::Settings['exclude']['users'],
                 type: :array
    class_option :'exclude-groups',
                 required: false,
                 default: Berta::Settings['exclude']['groups'],
                 type: :array
    class_option :'exclude-clusters',
                 required: false,
                 default: Berta::Settings['exclude']['clusters'],
                 type: :array

    desc 'default', 'The default task to run'
    def default
      initialize_configuration(options)
      Berta::CommandExecutor.new.cleanup
    end
    default_task :default

    private

    def initialize_configuration(options)
      Berta::Settings['opennebula']['secret'] = options['opennebula-secret']
      Berta::Settings['opennebula']['endpoint'] = options['opennebula-endpoint']
      Berta::Settings['expiration']['offset'] = options['expiration-offset']
      Berta::Settings['expiration']['action'] = options['expiration-action']
      Berta::Settings['notification']['deadline'] = options['notification-deadline']
      Berta::Settings['exclude']['ids'] = options['exclude-ids']
      Berta::Settings['exclude']['users'] = options['exclude-users']
      Berta::Settings['exclude']['groups'] = options['exclude-groups']
      Berta::Settings['exclude']['clusters'] = options['exclude-clusters']
    end
  end
end
