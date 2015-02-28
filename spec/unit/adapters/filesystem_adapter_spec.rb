require 'spec_helper'

require_relative '../../../lib/locomotive/steam/adapters/filesystem.rb'

describe Locomotive::Steam::FilesystemAdapter do

  let(:mapper)  { instance_double('Mapper', name: :test) }
  let(:scope)   { instance_double('Scope', site: site, locale: nil, to_key: 'key') }
  let(:adapter) { Locomotive::Steam::FilesystemAdapter.new(nil) }

  describe '#key' do

    subject { adapter.key(:title, :in) }

    it { is_expected.to eq 'title.in' }

  end

  describe '#query' do

    let(:collection) { [OpenStruct.new(site_id: 42, name: 'Hello world')] }

    before do
      allow(mapper).to receive(:to_entity) { |arg| arg }
      allow(adapter).to receive(:collection).and_return(collection)
    end

    subject { adapter.query(mapper, scope) { where(name: 'Hello world') } }

    context 'not scoped by a site' do

      let(:site) { nil }
      it { expect(subject.first.name).to eq 'Hello world' }

    end

    context 'scoped by a site' do

      let(:site) { instance_double('Site', _id: 42) }
      it { expect(subject.first.name).to eq 'Hello world' }

      context 'unknown site id' do

        let(:site) { instance_double('Site', _id: 1) }
        it { expect(subject.first).to eq nil }

      end

    end

  end

end
