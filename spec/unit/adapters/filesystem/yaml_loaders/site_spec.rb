require 'spec_helper'

require_relative '../../../lib/locomotive/steam/adapters/filesystem/yaml_loaders/site.rb'

describe Locomotive::Steam::Adapters::Filesystem::YAMLLoaders::Site do

  let(:root_path) { default_fixture_site_path }
  let(:cache)     { NoCacheStore.new }
  let(:loader)    { Locomotive::Steam::Adapters::Filesystem::YAMLLoaders::Site.new(root_path, cache) }

  describe '#load' do

    subject { loader.load }

    it { expect(subject.first[:name]).to eq 'Sample website' }

  end

end
