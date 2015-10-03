require 'spec_helper'

require_relative '../../../lib/locomotive/steam/adapters/filesystem.rb'
require_relative '../../../lib/locomotive/steam/adapters/mongodb.rb'

describe Locomotive::Steam::SiteRepository do

  let(:repository) { described_class.new(adapter) }

  shared_examples_for 'a repository' do

    describe '#all' do
      subject { repository.all }
      it { expect(subject.size).to eq 1 }
    end

    describe '#query' do
      subject { repository.query { where(handle: 'sample') }.first }
      it { expect(subject.name).to eq 'Sample site' }
    end

    describe '#by_domain' do
      subject { repository.by_domain('sample.example.com') }
      it { expect(subject).not_to eq nil }
    end

  end

  context 'MongoDB' do

    let(:adapter) { Locomotive::Steam::MongoDBAdapter.new(database: 'steam_test', hosts: ['127.0.0.1:27017']) }

    it_behaves_like 'a repository'

  end

  context 'Filesystem' do

    let(:adapter) { Locomotive::Steam::FilesystemAdapter.new(default_fixture_site_path) }

    it_behaves_like 'a repository'

  end

end
