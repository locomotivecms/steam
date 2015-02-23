require 'spec_helper'

require_relative '../../../lib/locomotive/steam/adapters/filesystem.rb'

describe Locomotive::Steam::SiteRepository do

  let(:adapter)     { Locomotive::Steam::FilesystemAdapter.new(nil) }
  let(:repository)  { Locomotive::Steam::SiteRepository.new(adapter) }

  before do
    allow(adapter).to receive(:collection).and_return([{ name: 'Acme', handle: 'acme', domains: ['example.org'] }])
    adapter.cache = NoCacheStore.new
  end

  describe '#by_handle_or_domain' do

    let(:handle)  { nil }
    let(:domains) { nil }

    subject { repository.by_handle_or_domain(handle, domains) }

    it { expect(subject).to eq nil }

    context 'handle' do

      let(:handle) { 'acme' }
      it { expect(subject.class).to eq Locomotive::Steam::Site }
      it { expect(subject.name).to eq 'Acme' }

    end

    context 'domain' do

      let(:domains) { 'example.org' }
      it { expect(subject.name).to eq 'Acme' }

    end

  end

end
