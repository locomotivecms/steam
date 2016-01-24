require 'spec_helper'

require_relative '../../../../../lib/locomotive/steam/adapters/filesystem/yaml_loader.rb'
require_relative '../../../../../lib/locomotive/steam/adapters/filesystem/yaml_loaders/site.rb'

describe Locomotive::Steam::Adapters::Filesystem::YAMLLoaders::Site do

  let(:site_path) { default_fixture_site_path }
  let(:loader)    { described_class.new(site_path) }

  describe '#load' do

    subject { loader.load(nil).first }

    it { expect(subject[:name]).to eq 'Sample site' }

    describe '#metafields_schema' do

      subject { loader.load(nil).first[:metafields_schema] }

      it 'loads the full schema' do
        expect(subject.count).to eq 2
      end

    end

  end

end
