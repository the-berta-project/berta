require 'berta'
require 'webmock/rspec'
require 'vcr'

WebMock.disable_net_connect!(allow_localhost: true)

VCR.configure do |config|
  config.cassette_library_dir = 'spec/cassettes'
  config.hook_into :webmock
end

RSpec.configure do |config|
  config.extend VCR::RSpec::Macros
end
