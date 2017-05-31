require 'spec_helper'

describe Berta::Service do
  subject(:service) { described_class.new('oneadmin:opennebula', 'http://localhost:2633/RPC2') }

  describe '#new' do
    it 'returns instace of Service with given data' do
      expect(service.endpoint).not_to be_empty
    end

    it 'connects to endpoint' do
      expect { service.client.get_version }.not_to raise_error
    end
  end

  describe '.running_vms' do
    context 'with exclude filter' do
      context 'with no params' do
        before do
          Berta::Settings['filter']['type'] = 'exclude'
          service.create_filter
        end

        after do
          Berta::Settings.reload!
        end

        it 'returns all 2 vms', :vcr do
          vms = service.running_vms
          expect(vms.length).to eq(2)
        end
      end

      context 'with ids' do
        before do
          Berta::Settings['filter']['type'] = 'exclude'
          Berta::Settings['filter']['ids'] = ['3']
          service.create_filter
        end

        after do
          Berta::Settings.reload!
        end

        it 'filters out 1 vm', :vcr do
          vms = service.running_vms
          expect(vms.length).to eq(1)
        end
      end

      context 'with users' do
        before do
          Berta::Settings['filter']['type'] = 'exclude'
          Berta::Settings['filter']['users'] = ['oneadmin']
          service.create_filter
        end

        after do
          Berta::Settings.reload!
        end

        it 'filters out all vms', :vcr do
          vms = service.running_vms
          expect(vms.length).to eq(0)
        end
      end

      context 'with groups' do
        before do
          Berta::Settings['filter']['type'] = 'exclude'
          Berta::Settings['filter']['groups'] = ['oneadmin']
          service.create_filter
        end

        after do
          Berta::Settings.reload!
        end

        it 'filters out all vms', :vcr do
          vms = service.running_vms
          expect(vms.length).to eq(0)
        end
      end

      context 'with clusters' do
        before do
          Berta::Settings['filter']['type'] = 'exclude'
          Berta::Settings['filter']['clusters'] = ['default']
          service.create_filter
        end

        after do
          Berta::Settings.reload!
        end

        it 'filters out all vms', :vcr do
          vms = service.running_vms
          expect(vms.length).to eq(0)
        end
      end

      context 'with combined params' do
        before do
          Berta::Settings['filter']['type'] = 'exclude'
          Berta::Settings['filter']['ids'] = ['2']
          Berta::Settings['filter']['groups'] = ['noexist']
          Berta::Settings['filter']['cluster'] = ['noexist']
          service.create_filter
        end

        after do
          Berta::Settings.reload!
        end

        it 'filters out 1 vm', :vcr do
          vms = service.running_vms
          expect(vms.length).to eq(1)
        end
      end
    end

    context 'with include filter' do
      context 'with no params' do
        before do
          Berta::Settings['filter']['type'] = 'include'
          service.create_filter
        end

        after do
          Berta::Settings.reload!
        end

        it 'returns all 2 vms', :vcr do
          vms = service.running_vms
          expect(vms.length).to eq(0)
        end
      end

      context 'with ids' do
        before do
          Berta::Settings['filter']['type'] = 'include'
          Berta::Settings['filter']['ids'] = ['2']
          service.create_filter
        end

        after do
          Berta::Settings.reload!
        end

        it 'filters out 1 vm', :vcr do
          vms = service.running_vms
          expect(vms.length).to eq(1)
        end
      end

      context 'with users' do
        before do
          Berta::Settings['filter']['type'] = 'include'
          Berta::Settings['filter']['users'] = ['oneadmin']
          service.create_filter
        end

        after do
          Berta::Settings.reload!
        end

        it 'returns all vms', :vcr do
          vms = service.running_vms
          expect(vms.length).to eq(2)
        end
      end

      context 'with groups' do
        before do
          Berta::Settings['filter']['type'] = 'include'
          Berta::Settings['filter']['groups'] = ['oneadmin']
          service.create_filter
        end

        after do
          Berta::Settings.reload!
        end

        it 'returns all vms', :vcr do
          vms = service.running_vms
          expect(vms.length).to eq(2)
        end
      end

      context 'with clusters' do
        before do
          Berta::Settings['filter']['type'] = 'include'
          Berta::Settings['filter']['clusters'] = ['default']
          service.create_filter
        end

        after do
          Berta::Settings.reload!
        end

        it 'returns all vms', :vcr do
          vms = service.running_vms
          expect(vms.length).to eq(2)
        end
      end

      context 'with combined params' do
        before do
          Berta::Settings['filter']['type'] = 'include'
          Berta::Settings['filter']['ids'] = ['2']
          Berta::Settings['filter']['clusters'] = ['default']
          service.create_filter
        end

        after do
          Berta::Settings.reload!
        end

        it 'returns all vms', :vcr do
          vms = service.running_vms
          expect(vms.length).to eq(2)
        end
      end
    end
  end

  # TODO: user_vms
end
