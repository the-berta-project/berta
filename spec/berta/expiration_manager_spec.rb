require 'spec_helper'

describe Berta::ExpirationManager do
  subject(:expiration_manager) { described_class.new }
  let(:service) { Berta::Service.new('oneadmin:opennebula', 'http://localhost:2633/RPC2') }

  describe '.add_default_expiration' do
    before do
      allow(Time).to receive(:now).and_return(Time.at(1_488_186_041))
    end

    context 'with no expiration date on vms', :vcr do
      it 'sets default expiration to all vms' do
        service.running_vms.each \
          { |vm| expect(expiration_manager.add_default_expiration(vm, vm.expirations).length).to eq(1) }
      end
    end

    context 'with good expiration date on vms', :vcr do
      it 'does nothing' do
        service.running_vms.each \
          { |vm| expect(expiration_manager.add_default_expiration(vm, vm.expirations).length).to eq(1) }
      end
    end

    context 'with different action expiration set', :vcr do
      it 'add correct one' do
        service.running_vms.each \
          { |vm| expect(expiration_manager.add_default_expiration(vm, vm.expirations).length).to eq(2) }
      end
    end
  end

  describe '.remove_invalid_expirations' do
    context 'with no expiration date on vms', :vcr do
      it 'does nothing' do
        service.running_vms.each \
          { |vm| expect(expiration_manager.remove_invalid_expirations(vm.expirations).length).to eq(0) }
      end
    end

    context 'with valid expiration date on vms', :vcr do
      it 'does nothing' do
        service.running_vms.each \
          { |vm| expect(expiration_manager.remove_invalid_expirations(vm.expirations).length).to eq(1) }
      end
    end

    context 'with invalid expiration date on vms', :vcr do
      it 'deletes all invalid expiration dates' do
        service.running_vms.each \
          { |vm| expect(expiration_manager.remove_invalid_expirations(vm.expirations).length).to eq(0) }
      end
    end
  end

  describe '.update_expirations' do
    before do
      Berta::Settings['expiration']['action'] = 'terminate-hard'
      allow(Time).to receive(:now).and_return(Time.at(1_487_937_346))
    end

    after do
      Berta::Settings.reload!
    end

    context 'with no expirations set on vms', :vcr do
      it 'sets default expiration to all vms' do
        expiration_manager.update_expirations(service.running_vms)
        service.running_vms.each do |vm|
          expect(vm.expirations.length).to eq(1)
          expect(vm.expirations[0].action).to eq(Berta::Settings.expiration.action)
        end
      end
    end

    context 'with default expirations set on vms', :vcr do
      it 'changes nothing' do
        expiration_manager.update_expirations(service.running_vms)
        service.running_vms.each do |vm|
          expect(vm.expirations.length).to eq(1)
          expect(vm.expirations[0].action).to eq(Berta::Settings.expiration.action)
        end
      end
    end

    context 'with default expirations set on vms and valid expiration date', :vcr do
      it 'changes nothing' do
        expiration_manager.update_expirations(service.running_vms)
        service.running_vms.each do |vm|
          expect(vm.expirations.length).to eq(2)
        end
      end
    end

    context 'with default, valid and invalid expiration date set on vms', :vcr do
      it 'deletes only invalid expiration date' do
        expiration_manager.update_expirations(service.running_vms)
        service.running_vms.each do |vm|
          expect(vm.expirations.length).to eq(2)
        end
      end
    end

    context 'with valid and invalid expiration date set on vms', :vcr do
      it 'sets default expiration date and deletes invalid one' do
        expiration_manager.update_expirations(service.running_vms)
        service.running_vms.each do |vm|
          expect(vm.expirations.length).to eq(2)
        end
      end
    end
  end
end
