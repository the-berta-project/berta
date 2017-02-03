require 'spec_helper'

describe Berta::VirtualMachineHandler do
  let(:service) { Berta::Service.new('oneadmin:opennebula', 'http://localhost:2633/RPC2') }

  describe '#new' do
    it 'returns list of vm handlers', :vcr do
      vms = service.running_vms
      vms.each { |vm| expect(vm.handle).not_to be_nil }
    end
  end

  describe '.update_notified' do
    context 'with valid response', :vcr do
      it 'sets vms notified' do
        service.running_vms.each(&:update_notified)
        service.running_vms.each do |vm|
          expect(vm.handle['USER_TEMPLATE/NOTIFIED']).not_to be_nil
        end
      end
    end
  end

  describe '.notified' do
    context 'with all vms notified', :vcr do
      it 'gets when vm was notified' do
        service.running_vms.each do |vm|
          expect(vm.notified).not_to be_nil
        end
      end
    end

    context 'with no vms notified', :vcr do
      it 'returns only nils' do
        service.running_vms.each do |vm|
          expect(vm.notified).to be_nil
        end
      end
    end
  end

  describe '.should_notify?' do
    before(:each) do
      Berta::Settings['expiration']['action'] = 'suspend'
    end

    after(:each) do
      Berta::Settings.reload!
    end

    context 'with 1vm with 2schelude action done', :vcr do
      it 'return false' do
        expect(service.running_vms.first.should_notify?).to be_falsey
      end
    end
  end

  describe '.add_expiration' do
    context 'vms have no expiration set', :vcr do
      it 'updates expiration date' do
        offset = Time.now.to_i + Berta::Settings.expiration_offset
        service.running_vms.each do |vm|
          vm.add_expiration(offset, Berta::Settings.expiration.action)
        end
        service.running_vms.each do |vm|
          expect(vm.handle['USER_TEMPLATE/SCHED_ACTION/ID']).to eq('0')
          expect(vm.handle['USER_TEMPLATE/SCHED_ACTION/ACTION']).to eq(Berta::Settings.expiration.action)
        end
      end
    end

    context 'vms have one expiration set', :vcr do
      it 'updates expiration date' do
        service.running_vms.each do |vm|
          vm.add_expiration(Time.now.to_i, 'resume')
        end
        service.running_vms.each do |vm|
          expect(vm.expirations.length).to eq(2)
        end
      end
    end
  end

  describe '.expirations' do
    context 'with vms with only 1 expiration date', :vcr do
      it 'returns array of expirations' do
        service.running_vms.each do |vm|
          exps = vm.expirations
          expect(exps.length).to eq(1)
        end
      end
    end

    context 'with vms with 2 expiration dates', :vcr do
      it 'returns array of expirations' do
        service.running_vms.each do |vm|
          exps = vm.expirations
          expect(exps.length).to eq(2)
        end
      end
    end

    context 'with vms with no expiration dates', :vcr do
      it 'returns array of expirations that is empty' do
        service.running_vms.each do |vm|
          exps = vm.expirations
          expect(exps.length).to eq(0)
        end
      end
    end
  end

  describe '.update_expirations' do
    context 'with empty array', :vcr do
      it 'wont change anything' do
        service.running_vms.each do |vm|
          old_length = vm.expirations.length
          vm.update_expirations([])
          expect(vm.expirations.length).to eq(old_length)
        end
      end
    end

    context 'with one expiration', :vcr do
      it 'sets all vms exactly one expiration' do
        service.running_vms.each do |vm|
          vm.update_expirations([Berta::Entities::Expiration.new(0,
                                                                 Time.now.to_i + 3600,
                                                                 Berta::Settings.expiration.action)])
          expect(vm.expirations.length).to eq(1)
        end
      end
    end
  end

  describe '.default_expiration' do
    context 'without any expiration', :vcr do
      it 'return nil' do
        service.running_vms.each do |vm|
          expect(vm.default_expiration).to be_nil
        end
      end
    end

    context 'with only default expiration set', :vcr do
      it 'return default expiration' do
        service.running_vms.each do |vm|
          expect(vm.default_expiration).not_to be_nil
        end
      end
    end

    context 'with valid expiration but not default one', :vcr do
      it 'return nil' do
        service.running_vms.each do |vm|
          expect(vm.default_expiration).to be_nil
        end
      end
    end

    context 'with valid expiration and default expiration', :vcr do
      it 'return default expiration' do
        service.running_vms.each do |vm|
          expect(vm.default_expiration).not_to be_nil
          expect(vm.default_expiration.action).to eq(Berta::Settings.expiration.action)
        end
      end
    end

    context 'with invalid expiration with default action', :vcr do
      it 'return nil' do
        service.running_vms.each do |vm|
          expect(vm.default_expiration).to be_nil
        end
      end
    end
  end
end
