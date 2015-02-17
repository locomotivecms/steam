require 'spec_helper'

describe Locomotive::Steam::Repositories::Filesystem::YAMLLoaders::Page do

  let(:root_path)       { default_fixture_site_path }
  let(:default_locale)  { :en }
  let(:cache)           { NoCacheStore.new }
  let(:loader)          { Locomotive::Steam::Repositories::Filesystem::YAMLLoaders::Page.new(root_path, default_locale, cache) }

  describe '#list_of_attributes' do

    subject { loader.list_of_attributes.sort { |a, b| a[:_fullpath] <=> b[:_fullpath] } }

    it 'tests various stuff' do
      expect(subject.size).to eq 21
      expect(subject.first[:title]).to eq({ en: 'Page not found' })
    end

  end

end
