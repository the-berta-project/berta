require 'spec_helper'

describe Berta::CommandExecutor do
  # subject(:command_executor) { described_class.new }

  describe '.cleanup' do
    context 'in real world', :vcr do
      before do
        allow(Time).to receive(:now).and_return(Time.at(1_495_704_318))
      end

      let(:command_executor) do
        Berta::Settings['filter']['type'] = 'exclude'
        Berta::Settings['filter']['ids'] = ['1']
        Berta::Settings['filter']['users'] = ['tester']
        Berta::Settings['opennebula']['secret'] = 'oneadmin:opennebula'
        Berta::Settings['opennebula']['endpoint'] = 'http://localhost:2633/RPC2'
        ce = described_class.new
        Mail::TestMailer.deliveries.clear
        Mail.defaults { delivery_method :test }
        ce
      end

      let(:observer) do
        Berta::Service.new(Berta::Settings['opennebula']['secret'],
                           Berta::Settings['opennebula']['endpoint'])
      end

      after do
        Berta::Settings.reload!
      end

      it 'runs correctly' do
        command_executor.cleanup
        expect(Mail::TestMailer.deliveries.length).to eq(1)
        vms = observer.running_vms
        expect(vms.length).to eq(3)
        expect((vms.find { |vmhs| vmhs.handle.id == 2 }).default_expiration).not_to be_nil
        expect((vms.find { |vmhs| vmhs.handle.id == 4 }).default_expiration).not_to be_nil
        expect((vms.find { |vmhs| vmhs.handle.id == 5 }).default_expiration).not_to be_nil
      end
    end
  end
end
