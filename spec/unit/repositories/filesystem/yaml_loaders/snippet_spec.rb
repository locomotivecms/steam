require 'spec_helper'

describe Locomotive::Steam::Repositories::Filesystem::YAMLLoaders::Snippet do

  let(:root_path)       { default_fixture_site_path }
  let(:default_locale)  { :en }
  let(:cache)           { NoCacheStore.new }
  let(:loader)          { Locomotive::Steam::Repositories::Filesystem::YAMLLoaders::Snippet.new(root_path, default_locale, cache) }

  describe '#list_of_attributes' do

    subject { loader.list_of_attributes }

    it 'tests various stuff' do
      expect(subject.size).to eq 4
      expect(subject.first[:name]).to eq('Song')
      expect(subject.first[:slug]).to eq('song')
      expect(subject[1][:slug]).to eq('a_complicated-one')
    end

  end

end
