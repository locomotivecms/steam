require File.join(File.dirname(__FILE__), '..', 'mongodb_helper')

require_relative '../../../lib/locomotive/steam/adapters/filesystem.rb'
require_relative '../../../lib/locomotive/steam/adapters/mongodb.rb'

describe Locomotive::Steam::PageRepository do

  shared_examples_for 'page repository' do

    let(:site)        { Locomotive::Steam::Site.new(_id: site_id, locales: %w(en fr nb)) }
    let(:locale)      { :en }
    let(:repository)  { Locomotive::Steam::PageRepository.new(adapter, site, locale) }

    describe '#all' do
      subject { repository.all }
      it { expect(subject.size).to eq 24 }
    end

    describe '#query' do
      subject { repository.query { where(fullpath: 'index') }.first }
      it { expect(subject.title[:en]).to eq 'Home page' }
    end

    describe '#by_handle' do
      subject { repository.by_handle('our-music') }
      it { expect(subject.title[:en]).to eq 'Music' }
    end

    describe '#by_fullpath' do
      subject { repository.by_fullpath('archives/news') }
      it { expect(subject.title[:en]).to eq 'News archive' }
    end

    describe '#matching_fullpath' do
      subject { repository.matching_fullpath(['songs/content_type_template', 'content_type_template/songs', 'songs/song-number-1']) }
      it { expect(subject.size).to eq 2 }
    end

  end

  context 'MongoDB' do

    it_should_behave_like 'page repository' do

      let(:site_id) { BSON::ObjectId.from_string('54eb49c12475804b2b000002') }
      let(:adapter) { Locomotive::Steam::MongoDBAdapter.new('steam_test', ['127.0.0.1:27017']) }

    end

  end

  context 'Filesystem' do

    it_should_behave_like 'page repository' do

      let(:site_id) { 1 }
      let(:adapter) { Locomotive::Steam::FilesystemAdapter.new(default_fixture_site_path) }

      after(:all) { Locomotive::Steam::Adapters::Filesystem::SimpleCacheStore.new.clear }

    end

  end

end
