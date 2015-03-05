require 'spec_helper'

require_relative '../../../lib/locomotive/steam/adapters/filesystem.rb'
require_relative '../../../lib/locomotive/steam/adapters/mongodb.rb'

describe Locomotive::Steam::ContentEntryRepository do

  shared_examples_for 'a repository' do

    let(:site)          { Locomotive::Steam::Site.new(_id: site_id, locales: %w(en fr nb)) }
    let(:locale)        { :en }
    let(:repository)    { described_class.new(adapter, site, locale) }

    let(:type_repository) { Locomotive::Steam::ContentTypeRepository.new(adapter, site, locale) }
    let(:type)  { type_repository.by_slug('bands') }

    describe '#all' do
      subject { repository.with(type).all }
      it { expect(subject.size).to eq 3 }
    end

    # describe '#by_slug' do
    #   subject { repository.by_slug('bands') }
    #   it { expect(subject.description).to eq 'List of bands' }
    # end

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
