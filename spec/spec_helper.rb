require 'berta'
require 'webmock/rspec'
require 'vcr'
require 'mail'

WebMock.disable_net_connect!(allow_localhost: true)

VCR.configure do |config|
  config.cassette_library_dir = 'spec/cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!
end

Mail.defaults do
  delivery_method :test
end
