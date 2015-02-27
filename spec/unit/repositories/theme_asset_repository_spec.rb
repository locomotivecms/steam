require 'spec_helper'

require_relative '../../../lib/locomotive/steam/adapters/filesystem.rb'

describe Locomotive::Steam::ThemeAssetRepository do

  let(:theme_assets)  { [{ local_path: 'application.css', checksum: 42 }] }
  let(:locale)        { :en }
  let(:site)          { instance_double('Site', _id: 1, default_locale: :en, locales: [:en, :fr]) }
  let(:adapter)       { Locomotive::Steam::FilesystemAdapter.new(nil) }
  let(:repository)    { described_class.new(adapter, site, locale) }

  before do
    allow(adapter).to receive(:collection).and_return(theme_assets)
    adapter.cache = NoCacheStore.new
  end

  describe '#url_for' do

    let(:path) { 'main.css' }
    subject { repository.url_for(path) }

    it { is_expected.to eq '/main.css' }

  end

  describe '#checksums' do

    subject { repository.checksums }

    it { is_expected.to eq({ 'application.css' => 42 }) }

  end

end
