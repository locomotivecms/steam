require 'spec_helper'

require_relative '../../../lib/locomotive/steam/adapters/memory.rb'

describe Locomotive::Steam::MemoryAdapter do

  let(:collection)  { [OpenStruct.new(name: 'Hello world')] }
  let(:mapper)      { instance_double('Mapper', name: :test) }
  let(:scope)       { instance_double('Scope', locale: nil) }
  let(:adapter)     { Locomotive::Steam::MemoryAdapter.new(collection) }

  before { allow(mapper).to receive(:to_entity) { |arg| arg } }

  describe '#all' do

    subject { adapter.all(mapper, scope) }
    it { expect(subject.size).to eq 1 }

  end

  describe '#query' do

    subject { adapter.query(mapper, scope) { where(name: 'Hello world') } }
    it { expect(subject.size).to eq 1 }

  end

end
