require 'berta'
require 'webmock/rspec'
require 'vcr'
require 'mail'
require 'yell'
require 'settingslogic'
require 'coveralls'

Coveralls.wear!

WebMock.disable_net_connect!(allow_localhost: true)

VCR.configure do |config|
  config.cassette_library_dir = 'spec/cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!
end

Mail.defaults do
  delivery_method :test
end

Yell.new :file, '/dev/null', name: Object, level: 'error', format: Yell::DefaultFormat
# Yell.new :stdout, :name => Object, :level => 'debug', :format => Yell::DefaultFormat
Object.send :include, Yell::Loggable
