require 'spec_helper'

require_relative '../../../../lib/locomotive/steam/adapters/filesystem/simple_cache_store.rb'

describe Locomotive::Steam::Adapters::Filesystem::SimpleCacheStore do

  let(:store) { described_class.new }

  describe '#fetch' do

    subject { store.read(:title) }
    before { store.fetch(:title) { 'Hello world' } }

    it { is_expected.to eq 'Hello world' }

  end

  describe '#delete' do

    subject { store.fetch(:title) }
    before { store.fetch(:title) { 'Hello world' }; store.delete(:title) }

    it { is_expected.to eq nil }

  end

end
