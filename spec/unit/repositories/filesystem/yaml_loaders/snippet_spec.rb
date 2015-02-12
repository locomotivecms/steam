require 'spec_helper'

describe Locomotive::Steam::Repositories::Filesystem::YAMLLoaders::Snippet do

  let(:root_path)       { default_fixture_site_path }
  let(:default_locale)  { :en }
  let(:cache)           { NoCacheStore.new }
  let(:loader)          { Locomotive::Steam::Repositories::Filesystem::YAMLLoaders::Snippet.new(root_path, default_locale, cache) }

  describe '#list_of_attributes' do

    subject { loader.list_of_attributes.sort { |a, b| a[:name] <=> b[:name] } }

    it 'tests various stuff' do
      expect(subject.size).to eq 4
      expect(subject.first[:slug]).to eq('a_complicated-one')
      expect(subject[1][:name]).to eq('Footer')
      expect(subject[1][:slug]).to eq('footer')
    end

  end

end
