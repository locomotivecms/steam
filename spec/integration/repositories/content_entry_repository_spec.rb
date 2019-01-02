require 'spec_helper'

require_relative '../../../lib/locomotive/steam/adapters/filesystem.rb'
require_relative '../../../lib/locomotive/steam/adapters/mongodb.rb'

describe Locomotive::Steam::ContentEntryRepository do

  shared_examples_for 'a repository' do

    let(:site)              { Locomotive::Steam::Site.new(_id: site_id, locales: %w(en fr nb)) }
    let(:locale)            { :en }
    let(:type_repository)   { Locomotive::Steam::ContentTypeRepository.new(adapter, site, locale) }
    let(:repository)        { described_class.new(adapter, site, locale, type_repository).with(type) }
    let(:type)              { type_repository.by_slug('bands') }
    let(:target_type)       { type_repository.by_slug('songs') }
    let(:target_repository) { described_class.new(adapter, site, locale, type_repository).with(target_type) }

    describe '#all' do
      subject { repository.all }
      it { expect(subject.size).to eq 3 }
    end

    describe '#count' do
      subject { repository.count }
      it { is_expected.to eq 3 }
    end

    describe '#by_slug' do
      subject { repository.by_slug('alice-in-chains') }
      it { expect(subject.name).to eq 'Alice in Chains' }
    end

    describe '#exists?' do
      subject { repository.exists?(featured: true) }
      it { is_expected.to eq true }
    end

    describe '#first' do
      subject { repository.first }
      it { expect(subject.name).to eq 'Alice in Chains' }
    end

    describe '#last' do
      subject { repository.last }
      it { expect(subject.name).to eq 'The who' }
    end

    describe '#find' do
      subject { repository.find(entry_id) }
      it { expect(subject.name).to eq 'Pearl Jam' }
    end

    describe '#next' do
      let(:entry) { repository.find(entry_id) }
      subject     { repository.next(entry) }
      it { expect(subject.name).to eq 'The who' }
    end

    describe '#previous' do
      let(:entry) { repository.find(entry_id) }
      subject     { repository.previous(entry) }
      it { expect(subject.name).to eq 'Alice in Chains' }
    end

    describe 'filter by a select field' do
      subject { repository.all(kind: 'grunge') }
      it { expect(subject.map { |entry| entry[:name] }).to eq(['Alice in Chains', 'Pearl Jam']) }
    end

    describe 'filter by a belongs_to field' do
      subject { target_repository.all(band: 'the-who') }
      it { expect(subject.map { |entry| entry[:title] }).to eq(['Song #5', 'Song #6']) }
      context 'looking for a nil value and in a different locale' do
        before { target_repository.scope.locale = :fr }
        subject { target_repository.all(band: nil) }
        it { expect(subject.size).to eq 2 }
      end
    end

    describe '#group_by_select_option' do
      subject { repository.group_by_select_option(:kind) }
      it { expect(subject.map { |h| h[:name] }).to eq(%w(grunge rock country)) }
      it { expect(subject.map { |h| h[:entries].size }).to eq([2, 1, 0]) }
    end

    describe '#order_by' do
      let(:order_by) { 'name' }
      subject { repository.all(order_by: order_by) }
      it { expect(subject.map { |h| h[:name] }).to eq(['Alice in Chains', 'Pearl Jam', 'The who']) }
      context 'a field and a direction' do
        let(:order_by) { 'name.desc, leader asc' }
        it { expect(subject.map { |h| h[:name] }).to eq(['The who', 'Pearl Jam', 'Alice in Chains']) }
      end
    end

    describe '#create' do

      let(:attributes) { { title: 'Jeremy', band_id: 'pearl-jam', short_description: '"Jeremy" is a song by the American rock band Pearl Jam' } }
      let(:entry) { repository.with(target_type).build(attributes) }

      subject { repository.create(entry) }

      it { expect { subject }.to change { repository.all.size } }
      it { expect(subject._id).not_to eq nil }

      after { repository.delete(entry) }

    end

    describe '#inc' do

      let(:type) { type_repository.by_slug('songs') }
      let(:attributes) { { title: 'Jeremy', band_id: 'pearl-jam', short_description: '"Jeremy" is a song by the American rock band Pearl Jam', views: 41 } }
      let(:entry) { repository.with(type).build(attributes) }

      before { repository.create(entry) }

      subject { repository.inc(entry, :views) }

      it { expect(subject.views).to eq 42 }

      after { repository.delete(entry) }

    end

  end

  context 'MongoDB' do

    it_should_behave_like 'a repository' do

      let(:site_id)   { mongodb_site_id }
      let(:adapter)   { Locomotive::Steam::MongoDBAdapter.new(database: mongodb_database, hosts: ['127.0.0.1:27017']) }
      let(:entry_id)  { BSON::ObjectId.from_string('5baf7d38a953300567956448') }

    end

  end

  context 'Filesystem' do

    it_should_behave_like 'a repository' do

      let(:site_id)   { 1 }
      let(:adapter)   { Locomotive::Steam::FilesystemAdapter.new(default_fixture_site_path) }
      let(:entry_id)  { 'pearl-jam' }

      after(:all) { Locomotive::Steam::Adapters::Filesystem::SimpleCacheStore.new.clear }

      describe '#create' do
        let(:messages)  { type_repository.by_slug('messages') }
        let(:message)   { repository.with(messages).build(name: 'John', email: 'john@doe.net', message: 'Hello world!') }
        subject { repository.create(message) }
        it { expect { subject }.to change { repository.all.size } }
      end

    end

  end

end
