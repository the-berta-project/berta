require 'spec_helper'

describe Berta::VirtualMachineHandler do
  let(:service) { Berta::Service.new('oneadmin:opennebula', 'http://localhost:2633/RPC2') }

  describe '#new' do
    it 'return list of vm handlers', :vcr do
      vms = service.get_running_vms
      vmhs = vms.map |vm| { Berta::VirtualMachineHandler.new(vm) }
      vmhs.each |vmh| { expect(vmh.notified?).to be true }
    end
  end
end
