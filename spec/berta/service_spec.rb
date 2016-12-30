require 'spec_helper'

describe Berta::Service do
  subject(:service) { Berta::Service.new('oneadmin:opennebula', 'http://147.251.17.221:2633/RPC2') }

  describe '#new' do
    it 'return instace of Service with given data' do
      expect(service.instance_variable_get(:@endpoint)).not_to be_empty
    end

    it 'connects to endpoint' do
      expect { service.instance_variable_get(:@client).get_version }.not_to raise_error
    end
  end

  describe '.running_vms' do
    context 'with valid response' do
      use_vcr_cassette 'default'

      it 'gets running vms' do
        vms = service.running_vms
        expect(vms.count).to eq(3)
      end
    end

    context 'with wrong secret' do
      use_vcr_cassette 'wrong_authentication'
      let(:wrong_service) { Berta::Service.new('ahoj:miso', 'http://147.251.17.221:2633/RPC2') }

      it 'gets running vms' do
        expect { wrong_service.running_vms }.to raise_error Berta::Errors::OpenNebula::AuthenticationError
      end
    end

    context 'with wrong endpoint' do
      use_vcr_cassette 'wrong_endpoint'
      let(:wrong_service) { Berta::Service.new('oneadmin:opennebula', 'http://localhost/RPC2') }

      it 'gets running vms' do
        expect { wrong_service.running_vms }.to raise_error Berta::Errors::OpenNebula::ResourceRetrievalError
      end
    end
  end
end
