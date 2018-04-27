require 'spec_helper'

require_relative '../../../../../lib/locomotive/steam/adapters/filesystem/yaml_loader.rb'
require_relative '../../../../../lib/locomotive/steam/adapters/filesystem/yaml_loaders/section.rb'

describe Locomotive::Steam::Adapters::Filesystem::YAMLLoaders::Section do

  let(:site_path) { default_fixture_site_path }
  let(:loader)    { described_class.new(site_path) }

  describe '#load' do

    let(:scope) { instance_double('Scope') }

    subject { loader.load(scope).sort { |a, b| a[:name] <=> b[:name] } }

    it 'tests various stuff' do
      expect(subject.size).to eq 3
      expect(subject.first[:slug]).to eq('carousel')
      expect(subject[1][:name]).to eq('Footer')
      expect(subject[2][:name]).to eq('Header')
      expect(subject[2][:slug]).to eq('header')
    end

  end

end
