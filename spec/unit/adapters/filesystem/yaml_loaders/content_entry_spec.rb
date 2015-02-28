require 'spec_helper'

require_relative '../../../../../lib/locomotive/steam/adapters/filesystem/yaml_loader.rb'
require_relative '../../../../../lib/locomotive/steam/adapters/filesystem/yaml_loaders/content_entry.rb'

describe Locomotive::Steam::Adapters::Filesystem::YAMLLoaders::ContentEntry do

  let(:site_path)     { default_fixture_site_path }
  let(:content_type)  { instance_double('Articles', slug: 'bands') }
  let(:scope)         { instance_double('Scope', locale: :en, context: { content_type: content_type }) }
  let(:loader)        { described_class.new(site_path) }

  describe '#load' do

    subject { loader.load(scope).sort { |a, b| a[:_label] <=> b[:_label] } }

    it 'tests various stuff' do
      expect(subject.size).to eq 3
      expect(subject.first[:_label]).to eq 'Alice in Chains'
      expect(subject.first[:content_type]).to eq nil
    end

  end

end
