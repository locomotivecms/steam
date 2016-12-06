require 'spec_helper'

require_relative '../../../../../lib/locomotive/steam/adapters/filesystem/yaml_loader.rb'
require_relative '../../../../../lib/locomotive/steam/adapters/filesystem/yaml_loaders/page.rb'

describe Locomotive::Steam::Adapters::Filesystem::YAMLLoaders::Page do

  let(:site_path) { default_fixture_site_path }
  let(:loader)    { described_class.new(site_path) }

  describe '#load' do

    let(:scope) { instance_double('Scope', locale: :fr, default_locale: :en) }

    subject { loader.load(scope).sort { |a, b| a[:_fullpath] <=> b[:_fullpath] } }

    it 'tests various stuff' do
      expect(subject.size).to eq 33
      expect(subject.first[:title]).to eq(en: 'Page not found', fr: 'Page non trouvée')
      expect(subject[22][:is_layout]).to eq true
      expect(subject[22][:listed]).to eq false
      expect(subject[22][:published]).to eq false
      expect(subject[23][:slug]).to eq(en: 'music', fr: 'notre-musique')
      expect(subject[24][:_fullpath]).to eq 'songs'
      expect(subject[24][:template_path]).to eq(en: false)
    end

  end

end
