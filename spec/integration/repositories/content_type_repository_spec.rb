require 'spec_helper'

require_relative '../../../lib/locomotive/steam/adapters/filesystem.rb'
require_relative '../../../lib/locomotive/steam/adapters/mongodb.rb'

describe Locomotive::Steam::ContentTypeRepository do

  shared_examples_for 'a repository' do

    let(:site)        { Locomotive::Steam::Site.new(_id: site_id, locales: %w(en fr nb)) }
    let(:locale)      { :en }
    let(:repository)  { described_class.new(adapter, site, locale) }

    describe '#all' do
      subject { repository.all }
      it { expect(subject.size).to eq 5 }
    end

    describe '#by_slug' do
      subject { repository.by_slug('bands') }
      it { expect(subject.description).to eq 'List of bands' }
    end

    describe '#fields_for' do
      let(:type) { repository.by_slug('bands') }
      subject { repository.fields_for(type) }
      it { expect(subject.first.hint).to eq 'Name of the band' }
    end

    describe '#look_for_unique_fields' do
      let(:type) { repository.by_slug('bands') }
      subject { repository.look_for_unique_fields(type) }
      it { expect(subject.size).to eq 0 }
    end

    describe '#select_options' do
      let(:type) { repository.by_slug('updates') }
      subject { repository.select_options(type, :category) }
      it { expect(subject.size).to eq 4 }
      it { expect(subject.first.name.translations).to eq({ 'en' => 'General', 'fr' => 'Général' }) }
    end

  end

  context 'MongoDB' do

    it_should_behave_like 'a repository' do

      let(:site_id) { mongodb_site_id }
      let(:adapter) { Locomotive::Steam::MongoDBAdapter.new(database: 'steam_test', hosts: ['127.0.0.1:27017']) }

    end

  end

  context 'Filesystem' do

    it_should_behave_like 'a repository' do

      let(:site_id) { 1 }
      let(:adapter) { Locomotive::Steam::FilesystemAdapter.new(default_fixture_site_path) }

      after(:all) { Locomotive::Steam::Adapters::Filesystem::SimpleCacheStore.new.clear }

    end

  end

end
