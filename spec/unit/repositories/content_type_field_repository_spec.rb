require 'spec_helper'

require_relative '../../../lib/locomotive/steam/adapters/memory.rb'

describe Locomotive::Steam::ContentTypeFieldRepository do

  let(:collection)  { [{ name: 'title', type: 'string' }, { name: 'body', type: 'text' }] }
  let(:adapter)     { Locomotive::Steam::MemoryAdapter.new(nil) }
  let(:repository)  { described_class.new(adapter) }

  before { allow(adapter).to receive(:collection).and_return(collection) }

  describe '#by_name' do

    let(:name) { nil }

    subject { repository.by_name(name) }

    it { expect(subject).to eq nil }

    context 'with an existing name' do

      let(:name) { 'title' }
      it { expect(subject.type).to eq :string }

    end

  end

  describe '#no_associations' do

    let(:collection) { [{ name: 'title', type: 'string' }, { name: 'author', type: 'belongs_to' }] }

    subject { repository.no_associations }

    it { expect(subject.size).to eq 1 }
    it { expect(subject.size).to eq 1 }

  end

  describe '#unique' do

    let(:collection)  { [{ name: 'name', type: 'string' }, { name: 'email', type: 'email', unique: true }] }

    subject { repository.unique }

    it { expect(subject.keys).to eq ['email'] }

  end

end
