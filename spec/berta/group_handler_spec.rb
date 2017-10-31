require 'spec_helper'

describe Berta::GroupHandler do
  let(:service) { Berta::Service.new('oneadmin:opennebula', 'http://localhost:2633/RPC2') }

  before do
    stub_const('Berta::Notification::EMAIL_TEMPLATE', Tilt.new('spec/test_mail.erb'))
  end

  describe '#new' do
    let(:group_handler) { described_class.new('TEMPLATE/EMAIL' => 'me@you.com', 'NAME' => 'me') }

    it 'correctly initializes' do
      expect(group_handler).not_to be_nil
    end

    it 'has email' do
      expect(group_handler.instance_variable_get(:@email)).to eq('me@you.com')
    end

    it 'has name' do
      expect(group_handler.instance_variable_get(:@name)).to eq('me')
    end
  end

  describe '.notify' do
    before do
      allow(Time).to receive(:now).and_return(Time.at(1_509_445_130))
      Mail::TestMailer.deliveries.clear
    end

    context 'with noone to notify', :vcr do
      it 'sends 0 emails' do
        groups = service.groups
        groups.each { |g| g.notify(service.group_vms(g)) }
        expect(Mail::TestMailer.deliveries.length).to eq(0)
      end
    end

    context 'with 1 group to notify', :vcr do
      it 'sends 1 email' do
        groups = service.groups
        groups.each { |g| g.notify(service.group_vms(g)) }
        expect(Mail::TestMailer.deliveries.length).to eq(1)
      end
    end

    context 'with all groups to notify', :vcr do
      it 'sends multiple emails' do
        groups = service.groups
        groups.each { |g| g.notify(service.group_vms(g)) }
        expect(Mail::TestMailer.deliveries.length).to eq(2)
      end
    end
  end
end
