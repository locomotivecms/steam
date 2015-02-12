require 'spec_helper'

describe Locomotive::Steam::Repositories::Filesystem::ThemeAsset do

  let(:site)        { instance_double('Site', default_locale: :en, locales: [:en, :fr]) }
  let(:repository)  { Locomotive::Steam::Repositories::Filesystem::ThemeAsset.new(site) }

  describe '#url_for' do

    let(:path) { 'main.css' }
    subject { repository.url_for(path) }

    it { is_expected.to eq 'main.css' }

  end

  describe '#checksums' do

    subject { repository.checksums }

    it { is_expected.to eq({}) }

  end

end
