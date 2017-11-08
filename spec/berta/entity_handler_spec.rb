require 'spec_helper'

describe Berta::EntityHandler do
  let(:service) { Berta::Service.new('oneadmin:opennebula', 'http://localhost:2633/RPC2') }

  before do
    Berta::Settings['email-template'] = 'spec/test_mail.erb'
    allow(Time).to receive(:now).and_return(Time.at(1_510_143_336))
    Mail::TestMailer.deliveries.clear
  end

  describe '#new', :vcr do
    let(:entity_handler) { service.users.first }

    it 'correctly initializes' do
      expect(entity_handler).not_to be_nil
    end

    it 'has id' do
      expect(entity_handler.id).not_to be_nil
    end

    it 'has name' do
      expect(entity_handler.name).not_to be_nil
    end

    it 'has email' do
      expect(entity_handler.email).not_to be_nil
    end

    it 'has type' do
      expect(entity_handler.type).to eq('User')
    end
  end

  describe '.notify' do
    context 'for User' do
      context 'with noone to notify', :vcr do
        it 'wont send emails' do
          service.users.each { |u| u.notify(service.user_vms(u)) }
          expect(Mail::TestMailer.deliveries.length).to eq(0)
        end
      end

      context 'with someone to notify', :vcr do
        it 'will send 1 email' do
          service.users.each { |u| u.notify(service.user_vms(u)) }
          expect(Mail::TestMailer.deliveries.length).to eq(1)
        end
      end

      context 'with everyone to notify', :vcr do
        it 'will send 1 email' do
          service.users.each { |u| u.notify(service.user_vms(u)) }
          expect(Mail::TestMailer.deliveries.length).to eq(1)
        end
      end
    end

    context 'for Group' do
      context 'with noone to notify', :vcr do
        it 'wont send emails' do
          service.groups.each { |g| g.notify(service.group_vms(g)) }
          expect(Mail::TestMailer.deliveries.length).to eq(0)
        end
      end

      context 'with someone to notify', :vcr do
        it 'will send 1 email' do
          service.groups.each { |g| g.notify(service.group_vms(g)) }
          expect(Mail::TestMailer.deliveries.length).to eq(1)
        end
      end

      context 'with everyone to notify', :vcr do
        it 'will send 1 email' do
          service.groups.each { |g| g.notify(service.group_vms(g)) }
          expect(Mail::TestMailer.deliveries.length).to eq(1)
        end
      end
    end

    context 'for Both' do
      context '1 user to notify and 1 group to notify', :vcr do
        it 'will send 2 emails' do
          service.users.each { |u| u.notify(service.user_vms(u)) }
          expect(Mail::TestMailer.deliveries.length).to eq(1)
          service.groups.each { |g| g.notify(service.group_vms(g)) }
          expect(Mail::TestMailer.deliveries.length).to eq(2)
        end
      end
    end
  end
end
