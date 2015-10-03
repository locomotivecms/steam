require 'spec_helper'

require_relative '../../../lib/locomotive/steam/adapters/filesystem.rb'
require_relative '../../../lib/locomotive/steam/adapters/mongodb.rb'

describe Locomotive::Steam::ThemeAssetRepository do

  let(:site)        { Locomotive::Steam::Site.new(_id: site_id, locales: %w(en fr nb)) }
  let(:repository)  { described_class.new(adapter, site, :en) }

  context 'MongoDB' do

    let(:site_id) { mongodb_site_id }
    let(:adapter) { Locomotive::Steam::MongoDBAdapter.new(database: 'steam_test', hosts: ['127.0.0.1:27017']) }

    describe '#all' do
      subject { repository.all }
      it { expect(subject.size).to eq 16 }
    end

    describe '#url_for' do
      subject { repository.url_for('stylesheets/application.css') }
      it { is_expected.to eq "/sites/#{mongodb_site_id}/theme/stylesheets/application.css" }
    end

    describe '#checksums' do
      subject { repository.checksums }
      it { expect(subject.size).to eq 16 }
      it { expect(subject['stylesheets/application.css']).to eq '3bacf4c2b7877e230e6990d72dae7724' }
    end

  end

  context 'Filesystem' do

    let(:site_id) { 1 }
    let(:adapter) { Locomotive::Steam::FilesystemAdapter.new(default_fixture_site_path) }

    describe '#all' do
      subject { repository.all }
      it { expect(subject.size).to eq 16 }
    end

    describe '#url_for' do
      subject { repository.url_for('stylesheets/application.css') }
      it { is_expected.to eq '/stylesheets/application.css' }
    end

    describe '#checksums' do
      subject { repository.checksums }
      it { expect(subject).to eq({}) }
    end

    after(:all) { Locomotive::Steam::Adapters::Filesystem::SimpleCacheStore.new.clear }

  end

end
