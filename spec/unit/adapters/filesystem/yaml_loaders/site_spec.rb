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
        expect(subject.count).to eq 4
      end

    end

    context 'a different environment' do

      let(:loader) { described_class.new(site_path, :production) }

      it 'completes the data with the ones from the production environment' do
        expect(subject[:name]).to eq('My awesome site')
      end

      it 'localizes the sections_content from the production environment' do
        allow(loader).to receive(:_load).with(File.join(site_path, 'config', 'site.yml')).and_return(name: 'Test', locales: ['fr'])
        allow(loader).to receive(:_load).with(File.join(site_path, 'config', 'metafields_schema.yml')).and_return(nil)
        expect(subject[:sections_content]).to eq('fr' => { 'header' => { 'settings' => {
          'title' => 'Hello world' } } })
      end

    end

  end

end
