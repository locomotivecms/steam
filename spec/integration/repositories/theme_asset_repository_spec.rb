require 'spec_helper'

require_relative '../../../lib/locomotive/steam/adapters/filesystem.rb'
require_relative '../../../lib/locomotive/steam/adapters/mongodb.rb'

describe Locomotive::Steam::ThemeAssetRepository do

  let(:site)        { Locomotive::Steam::Site.new(_id: site_id, locales: %w(en fr nb)) }
  let(:repository)  { described_class.new(adapter, site, :en) }

  context 'MongoDB' do

    let(:site_id) { BSON::ObjectId.from_string('54eb49c12475804b2b000002') }
    let(:adapter) { Locomotive::Steam::MongoDBAdapter.new('steam_test', ['127.0.0.1:27017']) }

    describe '#url_for' do
      subject { repository.url_for('stylesheets/application.css') }
      it { is_expected.to eq '/sites/54eb49c12475804b2b000002/theme/stylesheets/application.css' }
    end

    describe '#checksums' do
      subject { repository.checksums }
      it { expect(subject.size).to eq 16 }
      it { expect(subject['stylesheets/application.css']).to eq 'aa017461d702a80ef8837e51e65deb4f' }
    end

  end

  context 'Filesystem' do

    let(:site_id) { 1 }
    let(:adapter) { Locomotive::Steam::FilesystemAdapter.new(default_fixture_site_path) }

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
