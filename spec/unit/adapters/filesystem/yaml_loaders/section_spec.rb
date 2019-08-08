require 'spec_helper'

require_relative '../../../../../lib/locomotive/steam/adapters/filesystem/yaml_loader.rb'
require_relative '../../../../../lib/locomotive/steam/adapters/filesystem/yaml_loaders/section.rb'

describe Locomotive::Steam::Adapters::Filesystem::YAMLLoaders::Section do

  let(:site_path) { default_fixture_site_path }
  let(:loader)    { described_class.new(site_path) }

  describe '#load' do

    let(:scope) { instance_double('Scope', default_locale: :en) }

    subject { loader.load(scope).sort { |a, b| a[:name] <=> b[:name] } }

    it 'tests various stuff' do
      expect(subject.size).to eq 3
      expect(subject.first[:slug]).to eq('carousel')
      expect(subject[1][:name]).to eq('Footer')
      expect(subject[2][:name]).to eq('Header')
      expect(subject[2][:slug]).to eq('header')
    end

  end

  describe '#load_file' do

    subject { loader.send(:load_file, filepath) }

    describe 'error in the json header' do

      let(:filepath) { File.join(default_fixture_site_path, '..', 'errors', 'section_bad_json_header.liquid') }

      it 'should throw an error' do
        expect { subject }.to raise_error(Locomotive::Steam::ParsingRenderingError)
      end

    end

    describe 'json content' do

      let(:filepath) { File.join(default_fixture_site_path, '..', 'errors', 'section_bad_json_content.liquid') }

      it 'should throw an error' do
        expect { subject }.to raise_error(Locomotive::Steam::JsonParsingError)
      end
    end

  end

end
