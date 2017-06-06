require 'spec_helper'

class TestHandle
  def initialize(state)
    @state = state
  end

  def state_str
    @state
  end

  def id
    0
  end
end

class TestVM
  attr_reader :handle

  def initialize(state)
    @handle = TestHandle.new(state)
  end
end

describe Berta::Utils::Filter do
  describe '.run' do
    context 'with empty filter' do
      let(:filter) { described_class.new([], [], [], []) }

      it 'filters out IGNORED_STATES' do
        vms = [TestVM.new('RUNNING'),
               TestVM.new('PENDING'),
               TestVM.new('STOPPED'),
               TestVM.new('PENDING'),
               TestVM.new('STOPPED'),
               TestVM.new('HOLD')]
        filtered = filter.run(vms)
        expect(filtered.length).to eq(3)
      end
    end
  end
end
