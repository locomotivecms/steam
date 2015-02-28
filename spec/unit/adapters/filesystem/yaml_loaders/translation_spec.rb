require 'spec_helper'

require_relative '../../../../../lib/locomotive/steam/adapters/filesystem/yaml_loader.rb'
require_relative '../../../../../lib/locomotive/steam/adapters/filesystem/yaml_loaders/translation.rb'

describe Locomotive::Steam::Adapters::Filesystem::YAMLLoaders::Translation do

  let(:site_path) { default_fixture_site_path }
  let(:loader)    { described_class.new(site_path) }

  describe '#load' do

    let(:scope) { instance_double('Scope', locale: :en) }

    subject { loader.load(scope) }

    it 'tests various stuff' do
      expect(subject.size).to eq 1
      expect(subject.first[:key]).to eq('powered_by')
      expect(subject.first[:values]).to eq({ 'en' => 'Powered by', 'fr' => 'Propulsé par' })
    end

  end

end
