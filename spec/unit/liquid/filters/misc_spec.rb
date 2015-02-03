require 'spec_helper'

describe Locomotive::Steam::Liquid::Filters::Misc do

  include ::Liquid::StandardFilters
  include Locomotive::Steam::Liquid::Filters::Base
  include Locomotive::Steam::Liquid::Filters::Misc

  it 'returns the input string every n occurences' do
    expect(str_modulo('foo', 0, 3)).to eq ''
    expect(str_modulo('foo', 1, 3)).to eq ''
    expect(str_modulo('foo', 2, 3)).to eq 'foo'
    expect(str_modulo('foo', 3, 3)).to eq ''
    expect(str_modulo('foo', 4, 3)).to eq ''
    expect(str_modulo('foo', 5, 3)).to eq 'foo'
  end

  it 'returns default values if the input is empty' do
    expect(default('foo', 42)).to eq 'foo'
    expect(default('', 42)).to eq 42
    expect(default(nil, 42)).to eq 42
  end

  describe 'index' do

    let(:array)     { [1, 2, 3, 4] }
    let(:position)  { 2 }
    subject { index(array, position) }

    it { is_expected.to eq 3 }

  end

  describe 'split' do

    let(:string) { nil }
    subject { split(string, ',') }

    it { is_expected.to eq [] }

    context 'a not nil value' do

      let(:string) { 'foo,bar'}

      it { is_expected.to eq %w(foo bar) }

    end

  end

  describe 'random' do

    context 'from an integer' do

      subject { random(4) }
      it { is_expected.to be_a_kind_of(Fixnum) }
      it { is_expected.to satisfy { |n| n >=0 && n < 4 } }

    end

    context 'from a string' do

      subject { random('4') }
      it { is_expected.to be_a_kind_of(Fixnum) }
      it { is_expected.to satisfy { |n| n >=0 && n < 4 } }

    end

  end

  it 'returns a random number' do
    random_number = random(4)
    expect(random_number.class).to eq Fixnum
  end

end
