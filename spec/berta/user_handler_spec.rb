require 'spec_helper'

describe Berta::UserHandler do
  let(:service) { Berta::Service.new('oneadmin:opennebula', 'http://localhost:2633/RPC2') }

  before do
    stub_const('Berta::Notification::EMAIL_TEMPLATE', Tilt.new('spec/test_mail.erb'))
  end

  describe '#new' do
    it 'returns list of user handlers', :vcr do
      users = service.users
      users.each { |user| expect(user.handle).not_to be_nil }
    end
  end

  describe '.notify' do
    context 'with noone to notify', :vcr do
      before do
        allow(Time).to receive(:now).and_return(Time.at(1_493_118_324))
        Mail::TestMailer.deliveries.clear
      end

      it 'wont send email' do
        users = service.users
        users.each { |user| user.notify(service.running_vms) }
        expect(Mail::TestMailer.deliveries.length).to eq(0)
      end
    end

    context 'with someone to notify', :vcr do
      before do
        allow(Time).to receive(:now).and_return(Time.at(1_493_714_247))
        Mail::TestMailer.deliveries.clear
      end

      it 'will send email' do
        users = service.users
        users.each { |user| user.notify(service.running_vms) }
        expect(Mail::TestMailer.deliveries.length).not_to eq(0)
      end
    end
  end
end
