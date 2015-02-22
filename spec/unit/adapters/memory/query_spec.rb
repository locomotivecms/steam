require 'spec_helper'

require_relative '../../../../lib/locomotive/steam/adapters/memory/dataset.rb'
require_relative '../../../../lib/locomotive/steam/adapters/memory/condition.rb'
require_relative '../../../../lib/locomotive/steam/adapters/memory/order.rb'
require_relative '../../../../lib/locomotive/steam/adapters/memory/query.rb'

describe Locomotive::Steam::Adapters::Memory::Query do

  let(:entry_1) { OpenStruct.new(name: 'foo', id: 1) }
  let(:entry_2) { OpenStruct.new(name: 'bar', id: 2) }
  let(:entry_3) { OpenStruct.new(name: 'zone', id: 3) }
  let(:records) { { 1 => entry_1, 2 => entry_2, 3 => entry_3 } }
  let(:dataset) { Locomotive::Steam::Adapters::Memory::Dataset.new(:test) }
  let(:locale)  { :en }

  let(:query)   { Locomotive::Steam::Adapters::Memory::Query }

  before { allow(dataset).to receive(:records).and_return(records) }

  describe '#limited' do
    specify do
      expect(
        query.new(dataset, locale) do
          limit(1)
        end.all
      ).to eq([entry_1])
    end
  end

  describe '#order_by' do

    context 'asc' do
      specify do
        expect(
          query.new(dataset, locale) do
            order_by('name asc')
          end.all.map(&:name)
        ).to eq(['bar', 'foo', 'zone'])
      end
    end

    context 'desc' do
      specify do
        expect(
          query.new(dataset, locale) do
            order_by('name desc')
          end.all.map(&:name)
        ).to eq(['zone', 'foo', 'bar'])
      end
    end
  end

  describe '#where' do
    specify do
      expect(
        query.new(dataset, locale) do
          where('name.eq' => 'foo').
          where('id.lt' => 2)
        end.all.map(&:name)
      ).to eq(['foo'])
    end
  end

end
