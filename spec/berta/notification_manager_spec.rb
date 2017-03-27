require 'spec_helper'

describe Berta::NotificationManager do
  subject(:notification_manager) { described_class.new(service) }

  let(:service) { Berta::Service.new('oneadmin:opennebula', 'http://localhost:2633/RPC2') }

  describe '.uids_to_notify' do
    before do
      allow(Time).to receive(:now).and_return(Time.at(1_485_858_004))
    end

    context 'with no vm to notify', :vcr do
      it 'return empty hash' do
        uidsvm = notification_manager.uids_to_notify(service.running_vms)
        expect(uidsvm).to be_empty
      end
    end

    context 'with no vms to notify, that have expiration set', :vcr do
      it 'return empty hash' do
        uidsvm = notification_manager.uids_to_notify(service.running_vms)
        expect(uidsvm).to be_empty
      end
    end

    context 'with 1 vm to notify 1 user', :vcr do
      before do
        allow(Time).to receive(:now).and_return(Time.at(1_486_809_255))
      end

      it 'return hash with 1uid with 1vm hash' do
        uidsvm = notification_manager.uids_to_notify(service.running_vms)
        expect(uidsvm.length).to eq(1)
        uidsvm.each_value { |vms| expect(vms.length).to eq(1) }
      end
    end

    context 'with 2 vms to notify 1 user', :vcr do
      it 'return hash with 1uid with 1vm hash' do
        uidsvm = notification_manager.uids_to_notify(service.running_vms)
        expect(uidsvm.length).to eq(1)
        uidsvm.each_value { |vms| expect(vms.length).to eq(2) }
      end
    end

    context 'with 1 vm that was notified for past expiration that should be notified', :vcr do
      before do
        allow(Time).to receive(:now).and_return(Time.at(1_490_288_146))
      end

      it 'return hash with 1uid with 1vm hash' do
        uidsvm = notification_manager.uids_to_notify(service.running_vms)
        expect(uidsvm.length).to eq(1)
        uidsvm.each_value { |vms| expect(vms.length).to eq(1) }
      end
    end
  end

  describe '.notify_users' do
    before do
      Mail::TestMailer.deliveries.clear
    end

    context 'with noone to notify', :vcr do
      it 'wont send email' do
        notification_manager.notify_users(service.running_vms)
        expect(Mail::TestMailer.deliveries.length).to eq(0)
      end
    end
  end
end
