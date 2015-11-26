require 'spec_helper'

require_relative '../../../../../lib/locomotive/steam/adapters/filesystem/yaml_loader.rb'
require_relative '../../../../../lib/locomotive/steam/adapters/filesystem/yaml_loaders/content_type.rb'

describe Locomotive::Steam::Adapters::Filesystem::YAMLLoaders::ContentType do

  let(:site_path) { default_fixture_site_path }
  let(:loader)    { described_class.new(site_path) }

  describe '#load' do

    let(:scope) { instance_double('Scope', locale: :en) }

    subject { loader.load(scope).sort { |a, b| a[:slug] <=> b[:slug] } }

    it 'tests various stuff' do
      expect(subject.size).to eq 5
      expect(subject.first[:slug]).to eq('bands')
      expect(subject.first[:entries_custom_fields].size).to eq 5
      expect(subject.first[:entries_custom_fields].first[:position]).to eq 0
    end

  end

  describe '#build_select_options_from_hash' do

    let(:options) { { en: ['General', 'Gigs', 'Bands'], fr: ['Général', 'Concerts', 'Groupes'] } }

    subject { loader.send(:build_select_options_from_hash, options) }

    it { is_expected.to eq [{ _id: 'General', name: { en: 'General', fr: 'Général' }, position: 0 }, { _id: 'Gigs', name: { en: 'Gigs', fr: 'Concerts' }, position: 1 }, { _id: 'Bands', name: { en: 'Bands', fr: 'Groupes' }, position: 2 }] }

  end

  describe '#build_select_options_from_array' do

    # let(:options) { { en: ['General', 'Gigs', 'Bands'], fr: ['Général', 'Concerts', 'Groupes'] } }
    let(:options) { [{ en: 'General', fr: 'Général' }, { en: 'Gigs', fr: 'Concerts'}, { en: 'Bands', fr: 'Groupes' }] }

    subject { loader.send(:build_select_options_from_array, options) }

    it { is_expected.to eq [{ _id: 'General', name: { en: 'General', fr: 'Général' }, position: 0 }, { _id: 'Gigs', name: { en: 'Gigs', fr: 'Concerts' }, position: 1 }, { _id: 'Bands', name: { en: 'Bands', fr: 'Groupes' }, position: 2 }] }

  end

end
