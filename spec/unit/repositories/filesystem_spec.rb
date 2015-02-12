require 'spec_helper'

describe Locomotive::Steam::Repositories::Filesystem do

  let(:site) { instance_double('Site', name: 'PCH') }
  let(:repositories) { Locomotive::Steam::Repositories::Filesystem.build_instance(site) }

  describe '#theme_asset' do

    subject { repositories.theme_asset }

    context 'by default' do

      it 'returns a class of ThemeAssetRepository' do
        expect(subject.class).to eq Locomotive::Steam::Repositories::Filesystem::ThemeAsset
      end

      it 'gets access to the site' do
        expect(subject.site.name).to eq 'PCH'
      end

    end

    context 'a different repository' do

      before do
        repositories.theme_asset = MyThemeAssetRepository.new(site)
      end

      it 'returns a class of ThemeAssetRepository' do
        expect(subject.class).to eq MyThemeAssetRepository
      end

      it 'gets access to the site' do
        expect(subject.site.name).to eq 'PCH'
      end

    end

  end

  class MyThemeAssetRepository < Struct.new(:site); end

end
