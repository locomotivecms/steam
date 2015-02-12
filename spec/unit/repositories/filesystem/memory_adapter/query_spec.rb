require 'spec_helper'

describe Locomotive::Steam::Repositories::Filesystem::MemoryAdapter::Query do

  let(:entry_1) { instance_double('Entry1', name: 'foo', id: 1) }
  let(:entry_2) { instance_double('Entry2', name: 'bar', id: 2) }
  let(:entry_3) { instance_double('Entry3', name: 'zone', id: 3) }
  let(:dataset) { [entry_1, entry_2, entry_3] }
  let(:locale)  { :en }

  let(:query)   { Locomotive::Steam::Repositories::Filesystem::MemoryAdapter::Query }

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
