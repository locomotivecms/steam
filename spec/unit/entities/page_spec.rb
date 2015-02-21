require 'spec_helper'

describe Locomotive::Steam::Page do

  let(:attributes) { {} }
  let(:page) { Locomotive::Steam::Page.new(attributes) }

  describe '#index?' do

    let(:attributes) { { fullpath: { en: 'foo/index' } } }

    subject { page.index? }
    it { is_expected.to eq false }

    context 'true' do
      let(:attributes) { { fullpath: { en: 'index' } } }
      it { is_expected.to eq true }
    end

  end

  describe '#not_found?' do

    let(:attributes) { { fullpath: { en: 'index' } } }

    subject { page.not_found? }
    it { is_expected.to eq false }

    context 'true' do
      let(:attributes) { { fullpath: { en: '404' } } }
      it { is_expected.to eq true }
    end

  end

  describe '#valid?' do

    subject { page.valid? }
    it { is_expected.to eq true }

  end

end
