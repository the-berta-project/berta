require 'spec_helper'

describe Berta::CommandExecutor do
  # subject(:command_executor) { described_class.new }

  describe '.cleanup' do
    before do
      stub_const('Berta::Notification::EMAIL_TEMPLATE', Tilt.new('spec/test_mail.erb'))
    end

    context 'in real world', :vcr do
      before do
        allow(Time).to receive(:now).and_return(Time.at(1_509_439_594))
      end

      let(:command_executor) do
        Berta::Settings['filter']['type'] = 'exclude'
        Berta::Settings['filter']['ids'] = ['2']
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
        expect(Mail::TestMailer.deliveries.length).to eq(2)
        vms = observer.running_vms
        expect(vms.length).to eq(2)
        expect((vms.find { |vmhs| vmhs.handle.id == 0 }).default_expiration).not_to be_nil
        expect((vms.find { |vmhs| vmhs.handle.id == 1 }).default_expiration).not_to be_nil
      end
    end
  end
end
