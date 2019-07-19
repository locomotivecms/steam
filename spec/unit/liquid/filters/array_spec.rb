require 'spec_helper'

describe 'Locomotive::Steam::Liquid::Filters::Array' do

  include ::Liquid::StandardFilters
  include Locomotive::Steam::Liquid::Filters::Base
  include Locomotive::Steam::Liquid::Filters::Array

  describe '#pop' do

    let(:array) { ['a', 'b', 'c'] }

    subject { pop(array) }

    it { is_expected.to eq(['a', 'b']) }

    context 'removing last n elements' do

      subject { pop(array, 2) }

      it { is_expected.to eq(['a']) }

    end

    context 'passing a non array input' do

      let(:array) { 'Hello world' }
      it { is_expected.to eq('Hello world') }

    end

  end

  describe '#push' do

    let(:array) { ['a', 'b', 'c'] }

    subject { push(array, 'd') }

    it { is_expected.to eq(['a', 'b', 'c', 'd']) }

    context 'passing a non array input' do

      let(:array) { 'Hello world' }
      it { is_expected.to eq('Hello world') }

    end

  end

  describe '#shift' do

    let(:array) { ['a', 'b', 'c'] }

    subject { shift(array) }

    it { is_expected.to eq(['b', 'c']) }

    context 'removing n first elements' do

      subject { shift(array, 2) }

      it { is_expected.to eq(['c']) }

    end

    context 'passing a non array input' do

      let(:array) { 'Hello world' }
      it { is_expected.to eq('Hello world') }

    end

  end

  describe '#unshift' do

    let(:array) { ['a', 'b', 'c'] }

    subject { unshift(array, '1') }

    it { is_expected.to eq(['1', 'a', 'b', 'c']) }

    context 'adding n elements' do

      subject { unshift(array, ['1', '2']) }

      it { is_expected.to eq(['1', '2', 'a', 'b', 'c']) }

    end

    context 'passing a non array input' do

      let(:array) { 'Hello world' }
      it { is_expected.to eq('Hello world') }

    end

  end

  describe '#in_groups_of' do

    let(:array) { (1..10).to_a }

    subject { in_groups_of(array, '3') }

    it { is_expected.to eq([[1,2,3],[4,5,6],[7,8,9],[10, nil, nil]]) }

    context 'passing fill_with argument: nil' do
      subject { in_groups_of(array, '3', nil) }
      it { is_expected.to eq([[1,2,3],[4,5,6],[7,8,9],[10, nil, nil]]) }
    end

    context 'passing fill_with argument: value' do
      subject { in_groups_of(array, '3', 'foo') }
      it { is_expected.to eq([[1,2,3],[4,5,6],[7,8,9],[10, 'foo', 'foo']]) }
    end

    context 'passing fill_with argument: false' do
      subject { in_groups_of(array, '3', false) }
      it { is_expected.to eq([[1,2,3],[4,5,6],[7,8,9],[10]]) }
    end

    context 'passing a non array input' do
      let(:array) { 'Hello world' }
      it { is_expected.to eq('Hello world') }
    end

  end

end
