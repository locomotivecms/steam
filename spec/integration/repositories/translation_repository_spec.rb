require File.join(File.dirname(__FILE__), '..', 'mongodb_helper')

require_relative '../../../lib/locomotive/steam/adapters/filesystem.rb'
require_relative '../../../lib/locomotive/steam/adapters/mongodb.rb'

describe Locomotive::Steam::TranslationRepository do

  shared_examples_for 'a repository' do

    let(:site)        { Locomotive::Steam::Site.new(_id: site_id, locales: %w(en fr nb)) }
    let(:locale)      { :en }
    let(:repository)  { described_class.new(adapter, site, locale) }

    describe '#all' do
      subject { repository.all }
      it { expect(subject.size).to eq 1 }
    end

    describe '#by_key' do
      subject { repository.by_key('powered_by') }
      it { expect(subject.values).to eq({ 'en' => 'Powered by', 'fr' => 'Propulsé par' }) }
    end

  end

  context 'MongoDB' do

    it_should_behave_like 'a repository' do

      let(:site_id) { BSON::ObjectId.from_string('54eb49c12475804b2b000002') }
      let(:adapter) { Locomotive::Steam::MongoDBAdapter.new('steam_test', ['127.0.0.1:27017']) }

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
