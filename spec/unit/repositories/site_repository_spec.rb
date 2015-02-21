require 'spec_helper'

require_relative '../../../lib/locomotive/steam/adapters/filesystem.rb'

describe Locomotive::Steam::SiteRepository do

  let(:adapter)     { Locomotive::Steam::FilesystemAdapter.new(default_fixture_site_path) }
  let(:repository)  { Locomotive::Steam::SiteRepository.new(adapter) }

  describe '#all' do

    subject { repository.all }

    it { expect(subject.size).to eq 1 }

  end

  describe '#query' do

    subject do
      repository.query { where(subdomain: 'sample') }.first
    end

    it { expect(subject.name).to eq 'Sample website' }

  end

end
