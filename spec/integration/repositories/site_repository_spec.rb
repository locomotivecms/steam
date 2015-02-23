require 'spec_helper'

require_relative '../../../lib/locomotive/steam/adapters/filesystem.rb'
require_relative '../../../lib/locomotive/steam/adapters/mongodb.rb'

describe Locomotive::Steam::SiteRepository do

  let(:repository) { Locomotive::Steam::SiteRepository.new(adapter) }

  context 'MongoDB' do

    let(:adapter) { Locomotive::Steam::MongoDBAdapter.new('steam_test', ['127.0.0.1:27017']) }

    describe '#all' do
      subject { repository.all }
      it { expect(subject.size).to eq 1 }
    end

    describe '#query' do
      subject { repository.query { where(subdomain: 'sample') }.first }
      it { expect(subject.name).to eq 'Sample website' }
    end

  end

  context 'Filesystem' do

    let(:adapter) { Locomotive::Steam::FilesystemAdapter.new(default_fixture_site_path) }

    describe '#all' do
      subject { repository.all }
      it { expect(subject.size).to eq 1 }
    end

    describe '#query' do
      subject { repository.query { where(subdomain: 'sample') }.first }
      it { expect(subject.name).to eq 'Sample website' }
    end

  end

end
