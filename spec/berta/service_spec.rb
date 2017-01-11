require 'spec_helper'

describe Berta::Service do
  subject(:service) { Berta::Service.new('oneadmin:opennebula', 'http://localhost:2633/RPC2') }

  describe '#new' do
    it 'returns instace of Service with given data' do
      expect(service.endpoint).not_to be_empty
    end

    it 'connects to endpoint' do
      expect { service.client.get_version }.not_to raise_error
    end
  end

  describe '.running_vms' do
    context 'with valid response', :vcr do
      it 'gets running vms' do
        vms = service.running_vms
        expect(vms.count).to eq(3)
      end
    end

    context 'with wrong secret', :vcr do
      let(:wrong_service) { Berta::Service.new('ahoj:miso', 'http://localhost:2633/RPC2') }

      it 'raises authentication error' do
        expect { wrong_service.running_vms }.to raise_error Berta::Errors::OpenNebula::AuthenticationError
      end
    end

    context 'with wrong endpoint', :vcr do
      let(:wrong_service) { Berta::Service.new('oneadmin:opennebula', 'http://remotehost:2633/RPC2') }

      it 'raises resource retrieval error' do
        expect { wrong_service.running_vms }.to raise_error Berta::Errors::OpenNebula::ResourceRetrievalError
      end
    end
  end
end
