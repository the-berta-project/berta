require 'spec_helper'

describe Berta::VirtualMachineHandler do
  let(:service) { Berta::Service.new('oneadmin:opennebula', 'http://localhost:2633/RPC2') }

  describe '#new' do
    it 'returns list of vm handlers', :vcr do
      vms = service.running_vms
      vmhs = vms.map { |vm| Berta::VirtualMachineHandler.new(vm) }
      vmhs.each { |vmh| expect(vmh.handle).not_to be_nil }
    end
  end

  describe '.update_notified' do
    context 'with valid response', :vcr do
      it 'sets vms notified' do
        service.running_vms.each do |vm|
          vmh = Berta::VirtualMachineHandler.new(vm)
          vmh.update_notified
        end
        service.running_vms.each do |vm|
          expect(vm['USER_TEMPLATE/NOTIFIED']).not_to be_nil
        end
      end
    end
  end

  describe '.notified' do
    context 'with all vms notified', :vcr do
      it 'gets when vm was notified' do
        service.running_vms.each do |vm|
          vmh = Berta::VirtualMachineHandler.new(vm)
          expect(vmh.notified).not_to be_nil
          expect(vmh.notified).to eq(1_484_044_327)
        end
      end
    end

    context 'with no vms notified', :vcr do
      it 'returns only nils' do
        service.running_vms.each do |vm|
          vmh = Berta::VirtualMachineHandler.new(vm)
          expect(vmh.notified).to be_nil
        end
      end
    end
  end

  describe '.notified?' do
    context 'with all vms notified', :vcr do
      it 'gets when vm was notified' do
        service.running_vms.each do |vm|
          vmh = Berta::VirtualMachineHandler.new(vm)
          expect(vmh.notified?).to be true
        end
      end
    end

    context 'with no vms notified', :vcr do
      it 'returns only false' do
        service.running_vms.each do |vm|
          vmh = Berta::VirtualMachineHandler.new(vm)
          expect(vmh.notified?).to be false
        end
      end
    end
  end

  describe '.update_expiration' do
    context 'with valid response', :vcr do
      it 'updates expiration date' do
        service.running_vms.each do |vm|
          vmh = Berta::VirtualMachineHandler.new(vm)
          vmh.update_expiration(1_484_049_636, 'suspend')
        end
        service.running_vms.each do |vm|
          expect(vm['USER_TEMPLATE/SCHED_ACTION/TIME']).to eq('1484049636')
          expect(vm['USER_TEMPLATE/SCHED_ACTION/ACTION']).to eq('suspend')
        end
      end
    end
  end

  describe '.expiration_time' do
    context 'with vms with expiration date set', :vcr do
      it 'gets vms expiration time' do
        service.running_vms.each do |vm|
          vmh = Berta::VirtualMachineHandler.new(vm)
          expect(vmh.expiration_time).to eq(1_484_049_636)
        end
      end
    end

    context 'with vms without expiration date', :vcr do
      it 'returns all nils' do
        service.running_vms.each do |vm|
          vmh = Berta::VirtualMachineHandler.new(vm)
          expect(vmh.expiration_time).to be_nil
        end
      end
    end
  end

  describe '.expiration_action' do
    context 'with vms with expiration action set', :vcr do
      it 'gets vms expiration action' do
        service.running_vms.each do |vm|
          vmh = Berta::VirtualMachineHandler.new(vm)
          expect(vmh.expiration_action).to eq('suspend')
        end
      end
    end

    context 'with vms without expiration action', :vcr do
      it 'returns all nils' do
        service.running_vms.each do |vm|
          vmh = Berta::VirtualMachineHandler.new(vm)
          expect(vmh.expiration_action).to be_nil
        end
      end
    end
  end

  describe '.expiration?' do
    context 'with vms with expiration set', :vcr do
      it 'returns all true' do
        service.running_vms.each do |vm|
          vmh = Berta::VirtualMachineHandler.new(vm)
          expect(vmh.expiration?).to be true
        end
      end
    end

    context 'with vms without expiration set', :vcr do
      it 'returns all false' do
        service.running_vms.each do |vm|
          vmh = Berta::VirtualMachineHandler.new(vm)
          expect(vmh.expiration?).to be false
        end
      end
    end
  end
end
