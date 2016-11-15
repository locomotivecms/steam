require 'spec_helper'

require_relative '../../../lib/locomotive/steam/adapters/filesystem.rb'
require_relative '../../../lib/locomotive/steam/adapters/mongodb.rb'

describe Locomotive::Steam::ContentEntryService do

  shared_examples_for 'a content entry service' do

    let(:site)              { Locomotive::Steam::Site.new(_id: site_id, locales: %w(en fr nb)) }
    let(:locale)            { :en }
    let(:type_repository)   { Locomotive::Steam::ContentTypeRepository.new(adapter, site, locale) }
    let(:entry_repository)  { Locomotive::Steam::ContentEntryRepository.new(adapter, site, locale, type_repository) }
    let(:service)           { described_class.new(type_repository, entry_repository, locale) }
    let(:type)              { 'bands' }

    describe '#all' do
      subject { service.all(type) }
      it { expect(subject.size).to eq 3 }
      context 'with conditions' do
        subject { service.all(type, kind: 'grunge') }
        it { expect(subject.size).to eq 2 }
      end
      context 'as_json enabled' do
        subject { service.all(type, { kind: 'grunge' }, true) }
        it { expect(subject.first.slice('name', 'leader')).to eq('name' => 'Alice in Chains', 'leader' => 'Layne') }
      end
    end

    describe '#find' do
      let(:id_or_slug) { 'alice-in-chains'}
      subject { service.find(type, id_or_slug) }
      it { expect(subject.name).to eq 'Alice in Chains' }
      context 'with an id' do
        let(:id_or_slug) { entry_id }
        it { expect(subject.name).to eq 'Pearl Jam' }
      end
    end

  end

  context 'MongoDB' do

    it_should_behave_like 'a content entry service' do

      let(:site_id)   { mongodb_site_id }
      let(:adapter)   { Locomotive::Steam::MongoDBAdapter.new(database: 'steam_test', hosts: ['127.0.0.1:27017']) }
      let(:entry_id)  { BSON::ObjectId.from_string('5829ffa087f6435971756881') }

      describe '#create' do
        subject { service.create('messages', { name: 'John', email: 'john@doe.net', message: 'Hello world!' }) }
        it { expect { subject }.to change { service.all('messages').size } }
        it { expect(subject.name).to eq 'John' }
        after { service.delete('messages', subject._id) }
      end

      describe '#update' do
        let!(:message) { service.create('messages', { name: 'John', email: 'john@doe.net', message: 'Hello world!' }) }
        subject { service.update('messages', message._id, { name: 'Jane' }) }
        it { expect { subject }.not_to change { service.all('messages').size } }
        it { expect(subject.name).to eq 'Jane' }
        after { service.delete('messages', message._id) }
      end

    end

  end

  context 'Filesystem' do

    it_should_behave_like 'a content entry service' do

      let(:site_id)   { 1 }
      let(:adapter)   { Locomotive::Steam::FilesystemAdapter.new(default_fixture_site_path) }
      let(:entry_id)  { 'pearl-jam' }

      after(:all) { Locomotive::Steam::Adapters::Filesystem::SimpleCacheStore.new.clear }

      describe '#create' do

        let(:attributes) { { name: 'John', email: 'john@doe.net', message: 'Hello world!' } }

        subject { service.create('messages', attributes, true) }

        it { expect { subject }.to change { service.all('messages').size } }
        it { expect(subject['name']).to eq 'John' }
        it { expect(subject['errors'].blank?).to eq true }

        context 'missing attributes' do

          let(:attributes) { {} }

          it { expect { subject }.not_to change { service.all('messages').size } }
          it { expect(subject['errors']).to eq({ 'name' => ["can't be blank"], 'email' => ["can't be blank"], 'message' => ["can't be blank"] }) }

        end
      end

      describe '#update' do
        let!(:message) { service.create('messages', { name: 'John', email: 'john@doe.net', message: 'Hello world!' }) }
        subject { service.update('messages', message._id, { name: 'Jane' }, true) }
        it { expect { subject }.not_to change { service.all('messages').size } }
        it { expect(subject['name']).to eq 'Jane' }
      end

    end

  end

end
