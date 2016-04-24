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

  describe '#dup' do

    let(:translations) { { en: 'Hello world', fr: nil } }

    subject { field.dup }

    it 'gets a fresh copy of the translations' do
      expect(subject[:en]).to eq 'Hello world'
      expect(subject.translations.object_id).not_to eq field.translations.object_id
    end

  end

  describe '#to_json' do

    let(:translations) { { en: 'Hello world', fr: nil } }

    subject { field.to_json }

    it { is_expected.to eq("{\"en\":\"Hello world\",\"fr\":null}") }

  end

end
