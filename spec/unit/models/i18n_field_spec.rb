require 'spec_helper'

describe Locomotive::Steam::Models::I18nField do

  let(:name)          { 'title' }
  let(:translations)  { nil }
  let(:field)         { described_class.new(name, translations) }

  describe '#blank?' do

    subject { field.blank? }

    it { is_expected.to eq true }

    context 'with translations' do

      let(:translations) { { en: 'Hello world', fr: nil } }

      it { is_expected.to eq false }

    end

  end

  describe '#transform' do

    let(:translations) { { fr: 42, en: '42' } }

    before { field.transform(&:to_s) }

    subject { field.translations }

    it { is_expected.to eq('fr' => '42', 'en' => '42') }

  end

end
