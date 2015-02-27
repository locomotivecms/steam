require 'spec_helper'

require_relative '../../../lib/locomotive/steam/adapters/filesystem.rb'

describe Locomotive::Steam::TranslationRepository do

  let(:translations)  { [{ key: 'powered_by', values: { 'en' => 'Powered by Steam', 'fr' => 'Propulsé par Steam' } }] }
  let(:locale)        { :en }
  let(:site)          { instance_double('Site', _id: 1, default_locale: :en, locales: [:en, :fr]) }
  let(:adapter)       { Locomotive::Steam::FilesystemAdapter.new(nil) }
  let(:repository)    { described_class.new(adapter, site, locale) }

  before do
    allow(adapter).to receive(:collection).and_return(translations)
    adapter.cache = NoCacheStore.new
  end

  describe '#by_key' do

    let(:key) { nil }
    subject { repository.by_key(key) }

    it { is_expected.to eq nil }

    context 'existing translation' do

      let(:key) { 'powered_by' }
      it { expect(subject.values).to eq({ 'en' => 'Powered by Steam', 'fr' => 'Propulsé par Steam' }) }

    end

  end

end
