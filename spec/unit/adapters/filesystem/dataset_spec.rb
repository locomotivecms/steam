require 'spec_helper'

require_relative '../../../../lib/locomotive/steam/adapters/filesystem/dataset.rb'

describe Locomotive::Steam::Adapters::Filesystem::Dataset do

  let(:john) do
    {
      firstname: 'John',
      lastname: 'Doe',
      email: 'john@example.com',
      age: 24
    }
  end

  let(:jane) do
    {
      firstname: 'Jane',
      lastname: 'Doe',
      email: 'jane@example.com',
      age: 20
    }
  end

  let(:alex) do
    {
      firstname: 'Alex',
      lastname: 'Turam',
      email: 'alex@example.com',
      age: 26
    }
  end

  subject { Locomotive::Steam::Adapters::Filesystem::Dataset.new(:foo) } #(loader) }

  before do
    [john.to_hash, jane.to_hash, alex.to_hash].each do |record|
      subject.insert record
    end
  end

  describe '#all' do
    it { expect(subject.all).to eq [john.to_hash, jane.to_hash, alex.to_hash] }
  end

  describe '#find' do
    specify do
      expect(subject.find(john[:_id])).to eq(john.to_hash)
    end
  end

  describe '#update' do
    before do
      subject.update(jane.to_hash.merge(lastname: 'birkin'))
    end

    specify do
      expect(subject.find(jane[:_id]).fetch(:lastname)).to eq('birkin')
    end
  end

  describe '#exists?' do
    let(:dataset) { Locomotive::Steam::Adapters::Filesystem::Dataset.new(:dummy) }
    before do
      dataset.instance_variable_set('@records', { 1 => 'Record 1', 2 => 'Record 2' })
    end

    it { expect(dataset.exists?(2)).to eq true  }
    it { expect(dataset.exists?(3)).to eq false  }
    it { expect(dataset.exists?(nil)).to eq false  }

  end
end
