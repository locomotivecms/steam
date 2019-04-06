require 'spec_helper'

describe Locomotive::Steam::TranslatorService do

  let(:default_locale)  { 'en' }
  let(:repository)      { instance_double('Repository') }
  let(:service)         { described_class.new(repository, default_locale) }

  describe '#translate' do

    let(:key)           { 'example_test' }
    let(:input)         { 'example_test' }
    let(:locale)        { nil }
    let(:scope)         { nil }
    let(:interpolation) { {} }

    before do
      allow(repository).to receive(:group_by_key).and_return({ key => translation })
    end

    subject { service.translate(input, interpolation.merge('locale' => locale, 'scope' => scope)) }

    describe 'existing translation' do

      let(:translation) { { 'en' => 'Example text', 'es' => 'Texto de ejemplo' } }

      it { is_expected.to eq 'Example text' }

      describe 'specifying a locale' do

        let(:locale) { 'es' }
        it { is_expected.to eq 'Texto de ejemplo' }

      end

      describe "specifying a locale that doesn't exist" do

        let(:locale) { 'nl' }

        it 'reverts to default locale' do
          is_expected.to eq 'example_test'
        end

      end

      context 'with a scope' do

        let(:input)   { 'fr' }
        let(:locale)  { 'en' }
        let(:scope)   { 'locomotive.locales' }

        it { is_expected.to eq 'French' }

        context 'the translation has been overwritten for the site' do

          let(:key)         { 'locomotive_locales_fr' }
          let(:translation) { { 'en' => 'Français' } }

          it { is_expected.to eq 'Français' }

        end

      end

      describe 'interpolation' do

        let(:interpolation) { { 'name' => 'John' } }
        let(:translation)   { { 'en' => 'Hello {{ name }}', 'es' => 'Texto de ejemplo' } }

        it { is_expected.to eq 'Hello John' }

      end

      describe 'pluralization' do

        context 'zero' do

          let(:interpolation) { { 'count' => '0' } }
          let(:translation)   { { 'en' => 'No posts' } }

          before { expect(repository).to receive(:group_by_key).and_return({ 'example_test_zero' => translation }) }

          it { is_expected.to eq 'No posts' }

        end

        context 'one' do

          let(:interpolation) { { 'count' => '1' } }
          let(:translation)   { { 'en' => '1 post' } }

          before { expect(repository).to receive(:group_by_key).and_return({ 'example_test_one' => translation }) }

          it { is_expected.to eq '1 post' }

        end

        context 'two' do

          let(:interpolation) { { 'count' => 2 } }
          let(:translation)   { { 'en' => '2 posts' } }

          before { expect(repository).to receive(:group_by_key).and_return({ 'example_test_two' => translation }) }

          it { is_expected.to eq '2 posts' }

        end

        context 'other' do

          let(:interpolation) { { 'count' => 42 } }
          let(:translation)   { { 'en' => '{{ count }} posts' } }

          before { expect(repository).to receive(:group_by_key).and_return({ 'example_test_other' => translation }) }

          it { is_expected.to eq '42 posts' }

        end

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
