require 'spec_helper'

describe Berta::Service do
  subject(:service) { Berta::Service.new('oneadmin:opennebula', 'http://147.251.17.221:2633/RPC2') }

  describe '#new' do
    it 'return instace of Service with given data' do
      expect(service.instance_variable_get(:@endpoint)).not_to be_empty
    end

    it 'should connect to endpoint' do
      expect { service.instance_variable_get(:@client).get_version }.not_to raise_error
    end
  end

  describe '.running_vms' do
    context 'with valid response' do
      use_vcr_cassette 'default'

      it 'should get running vms' do
        vms = service.running_vms
        expect(vms.count).to eq(3)
      end
    end
  end
end
