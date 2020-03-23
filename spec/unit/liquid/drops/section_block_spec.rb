require 'spec_helper'

describe Locomotive::Steam::Liquid::Drops::SectionBlock do

  let(:section) { instance_double('Section', definition: { 'blocks' => [] }) }
  let(:block) { instance_double('block') }
  let(:index) { 0 }
  let(:drop) { described_class.new(section, block, index) }

  describe '#has_leaves?' do

    subject { drop.has_leaves? }

    it { is_expected.to eq false }

    context 'the block has leaves' do

      before { drop.leaves << instance_double('SectionBlock') }

      it { is_expected.to eq true }

    end

  end

end
