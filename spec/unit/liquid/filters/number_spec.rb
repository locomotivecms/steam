# encoding: utf-8

require 'spec_helper'

describe Locomotive::Steam::Liquid::Filters::Number do

  include Locomotive::Steam::Liquid::Filters::Number

  let(:environments)  { {} }
  let(:input)         { nil }
  let(:options)       { nil }

  let(:context)       { Liquid::Context.new(environments) }

  before { @context = context }

  it 'should not invoke directly the number_to_xxx methods' do
    expect(subject).not_to respond_to(:number_to_currency)
  end

  describe '#money' do

    subject { money(input, options) }

    context 'not a number' do

      it { expect(subject).to eq nil }

    end

    context 'a number' do

      let(:input) { 42.01 }

      it { expect(subject).to eq '$42.01' }

    end

    context 'with options' do

      let(:input) { 42.01 }
      let(:options) { ['unit: "€"', 'format: "%n %u"', 'precision: 1'] }

      it { expect(subject).to eq '42.0 €' }

    end

    context "one of the options is a liquid variable" do

      let(:environments)  { { 'my_unit' => 'Franc' } }

      let(:input) { 42.01 }
      let(:options) { ['unit: my_unit', 'format: "%n %u"'] }

      it { expect(subject).to eq '42.01 Franc' }

    end

  end

  describe '#percentage' do

    subject { percentage(input, options) }

    context 'not a number' do

      it { expect(subject).to eq nil }

    end

    context 'a number' do

      let(:input) { 42.01 }

      it { expect(subject).to eq '42.010%' }

    end

    context 'with options' do

      let(:input) { '42.01' }
      let(:options) { ['precision: 0'] }

      it { expect(subject).to eq '42%' }

    end

  end

end
