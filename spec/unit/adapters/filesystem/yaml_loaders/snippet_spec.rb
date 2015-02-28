require 'spec_helper'

require_relative '../../../../../lib/locomotive/steam/adapters/filesystem/yaml_loader.rb'
require_relative '../../../../../lib/locomotive/steam/adapters/filesystem/yaml_loaders/snippet.rb'

describe Locomotive::Steam::Adapters::Filesystem::YAMLLoaders::Snippet do

  let(:site_path) { default_fixture_site_path }
  let(:loader)    { described_class.new(site_path) }

  describe '#load' do

    let(:scope) { instance_double('Scope', locale: :en) }

    subject { loader.load(scope).sort { |a, b| a[:name] <=> b[:name] } }

    it 'tests various stuff' do
      expect(subject.size).to eq 4
      expect(subject.first[:slug]).to eq('a_complicated-one')
      expect(subject[1][:name]).to eq('Footer')
      expect(subject[1][:slug]).to eq('footer')
    end

  end

end
