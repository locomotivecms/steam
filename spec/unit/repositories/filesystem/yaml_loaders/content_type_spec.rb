require 'spec_helper'

describe Locomotive::Steam::Repositories::Filesystem::YAMLLoaders::ContentType do

  let(:root_path)       { default_fixture_site_path }
  let(:cache)           { NoCacheStore.new }
  let(:loader)          { Locomotive::Steam::Repositories::Filesystem::YAMLLoaders::ContentType.new(root_path, cache) }

  describe '#list_of_attributes' do

    subject { loader.list_of_attributes.sort { |a, b| a[:slug] <=> b[:slug] } }

    it 'tests various stuff' do
      expect(subject.size).to eq 5
      expect(subject.first[:slug]).to eq('bands')
    end

  end

end
