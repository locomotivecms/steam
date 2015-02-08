require 'spec_helper'

describe Liquid::StandardFilters do

  describe '#to_number' do

    subject { SimpleFilters.new.send(:to_number, obj) }

    context 'Integer' do
      let(:obj) { 42 }
      it { is_expected.to eq 42 }
    end

    context 'String (Integer)' do
      let(:obj) { '42' }
      it { is_expected.to eq 42 }
    end

    context 'String (Float)' do
      let(:obj) { '42.00' }
      it { is_expected.to eq 42.0 }
    end

    context 'Date' do
      let(:obj) { Date.parse('2007/06/29') }
      it { is_expected.to be >= 1183068000 }
    end

    context 'Time' do
      let(:obj) { Time.parse('2007/06/29 00:00:00') }
      it { is_expected.to be >= 1183068000 }
    end

    context 'DateTime' do
      let(:obj) { DateTime.parse('2007/06/29 00:00:00+0000') }
      it { is_expected.to eq 1183075200 }
    end

    context 'Other object' do
      let(:obj) { nil }
      it { is_expected.to eq 0 }
    end

  end

  class SimpleFilters
    include Liquid::StandardFilters
  end

end
