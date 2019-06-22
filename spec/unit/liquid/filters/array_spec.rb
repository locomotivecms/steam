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

end
