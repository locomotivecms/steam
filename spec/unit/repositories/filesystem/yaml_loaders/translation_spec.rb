require 'spec_helper'

describe Locomotive::Steam::Repositories::Filesystem::YAMLLoaders::Translation do

  let(:root_path)       { default_fixture_site_path }
  let(:cache)           { NoCacheStore.new }
  let(:loader)          { Locomotive::Steam::Repositories::Filesystem::YAMLLoaders::Translation.new(root_path, cache) }

  describe '#list_of_attributes' do

    subject { loader.list_of_attributes }

    it 'tests various stuff' do
      expect(subject.size).to eq 1
      expect(subject.first[:key]).to eq('powered_by')
      expect(subject.first[:values]).to eq({ en: 'Powered by', fr: 'Propulsé par' })
    end

  end

end
