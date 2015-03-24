require 'spec_helper'

require_relative '../../../lib/locomotive/steam/adapters/filesystem.rb'
require_relative '../../../lib/locomotive/steam/adapters/mongodb.rb'

describe Locomotive::Steam::PageRepository do

  shared_examples_for 'a repository' do

    let(:site)        { Locomotive::Steam::Site.new(_id: site_id, locales: %w(en fr nb)) }
    let(:locale)      { :en }
    let(:repository)  { described_class.new(adapter, site, locale) }

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

    describe '#template_for' do
      let(:type_repository)   { Locomotive::Steam::ContentTypeRepository.new(adapter, site, locale) }
      let(:type)              { type_repository.by_slug('songs') }
      let(:entry_repository)  { Locomotive::Steam::ContentEntryRepository.new(adapter, site, locale, type_repository).with(type) }
      let(:entry)             { entry_repository.by_slug('song-number-1') }
      subject { repository.template_for(entry) }
      it { expect(subject.title[:en]).to eq 'A song template' }
    end

    describe '#matching_fullpath' do
      subject { repository.matching_fullpath(['songs/content_type_template', 'content_type_template/songs', 'songs/song-number-1']) }
      it { expect(subject.size).to eq 2 }
    end

    describe '#root' do
      subject { repository.root }
      it { expect(subject.title[:en]).to eq 'Home page' }
      it { expect(subject.title[:fr]).to eq "Page d'accueil" }
    end

    describe '#parent_of' do
      let(:page) { repository.by_handle('about-us') }
      subject { repository.parent_of(page) }
      it { expect(subject.title[:en]).to eq 'Home page' }
    end

    describe '#ancestors_of' do
      let(:page) { repository.by_handle('about-us') }
      subject { repository.ancestors_of(page) }
      it { expect(subject.size).to eq 2 }
      it { expect(subject.first.title[:en]).to eq 'Home page' }
    end

    describe '#children_of' do
      let(:page) { repository.root }
      subject { repository.children_of(page) }
      it { expect(subject.size).to eq 14 }
    end

    describe '#editable_element_for' do
      let(:page) { repository.by_handle('about-us') }
      subject { repository.editable_element_for(page, 'banner', 'pitch') }
      it { expect(subject.content[:en]).to eq '<h2>About us</h2><p>Lorem ipsum...</p>' }
    end

  end

  context 'MongoDB' do

    it_should_behave_like 'a repository' do

      let(:site_id)       { BSON::ObjectId.from_string('54eb49c12475804b2b000002') }
      let(:adapter)       { Locomotive::Steam::MongoDBAdapter.new(database: 'steam_test', hosts: ['127.0.0.1:27017']) }

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
