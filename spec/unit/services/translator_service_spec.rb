require 'spec_helper'

describe Locomotive::Steam::TranslatorService do

  let(:default_locale)  { 'en' }
  let(:repository)      { instance_double('Repository') }
  let(:service)         { described_class.new(repository, default_locale) }

  describe '#translate' do

    let(:input)   { 'example_test' }
    let(:locale)  { nil }
    let(:scope)   { nil }

    before do
      allow(repository).to receive(:by_key).with('example_test').and_return(translation)
    end

    subject { service.translate(input, locale, scope) }

    describe 'existing translation' do

      let(:translation) { instance_double('Translation', values: { 'en' => 'Example text', 'es' => 'Texto de ejemplo' }) }

      it { is_expected.to eq 'Example text' }

      context 'specifying a locale' do

        let(:locale) { 'es' }
        it { is_expected.to eq 'Texto de ejemplo' }

      end

      context "specifying a locale that doesn't exist" do

        let(:locale) { 'nl' }

        it 'reverts to default locale' do
          is_expected.to eq 'example_test'
        end

      end

      context 'specifying a scope' do

        let(:input)   { 'fr' }
        let(:locale)  { 'en' }
        let(:scope)   { 'locomotive.locales' }

        it { is_expected.to eq 'French' }

      end

    end

    describe 'missing translation' do

      let(:locale)      { 'fr' }
      let(:translation) { nil }

      it { is_expected.to eq 'example_test' }

      it 'sends a notification' do
        payload = notification_payload_for('steam.missing_translation') { subject }
        expect(payload[:input]).to eq 'example_test'
        expect(payload[:locale]).to eq 'fr'
      end

    end

  end

end
