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
          expect(vm.notified).to eq(1_484_044_327)
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

  describe '.update_expiration' do
    context 'with valid response', :vcr do
      it 'updates expiration date' do
        service.running_vms.each do |vm|
          vm.update_expiration(1_484_049_636, 'suspend')
        end
        service.running_vms.each do |vm|
          expect(vm.handle['USER_TEMPLATE/SCHED_ACTION/TIME']).to eq('1484049636')
          expect(vm.handle['USER_TEMPLATE/SCHED_ACTION/ACTION']).to eq('suspend')
        end
      end
    end

    context 'with already set expiration date', :vcr do
      it 'updates expiration date to new one' do
        service.running_vms.each do |vm|
          vm.update_expiration(1_484_149_636, 'suspend')
        end
        service.running_vms.each do |vm|
          expect(vm.handle['USER_TEMPLATE/SCHED_ACTION/TIME']).to eq('1484149636')
          expect(vm.handle['USER_TEMPLATE/SCHED_ACTION/ACTION']).to eq('suspend')
        end
      end
    end
  end

  describe '.expiration_time' do
    context 'with vms with expiration date set', :vcr do
      it 'gets vms expiration time' do
        service.running_vms.each do |vm|
          expect(vm.expiration_time).to eq(1_484_049_636)
        end
      end
    end

    context 'with vms without expiration date', :vcr do
      it 'returns all nils' do
        service.running_vms.each do |vm|
          expect(vm.expiration_time).to be_nil
        end
      end
    end
  end

  describe '.expiration_action' do
    context 'with vms with expiration action set', :vcr do
      it 'gets vms expiration action' do
        service.running_vms.each do |vm|
          expect(vm.expiration_action).to eq('suspend')
        end
      end
    end

    context 'with vms without expiration action', :vcr do
      it 'returns all nils' do
        service.running_vms.each do |vm|
          expect(vm.expiration_action).to be_nil
        end
      end
    end
  end

  describe '.expiration?' do
    context 'with vms with expiration set', :vcr do
      it 'returns all true' do
        service.running_vms.each do |vm|
          expect(vm.expiration?).to be_truthy
        end
      end
    end

    context 'with vms without expiration set', :vcr do
      it 'returns all false' do
        service.running_vms.each do |vm|
          expect(vm.expiration?).to be_falsy
        end
      end
    end
  end
end
