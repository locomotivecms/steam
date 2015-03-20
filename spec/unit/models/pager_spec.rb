require 'spec_helper'

describe Locomotive::Steam::Models::Pager do

  let(:page)        { 1 }
  let(:per_page)    { 2 }
  let(:source)      { ['MongoDB', 'Rails', 'Liquid', 'Rack', 'Devise'] }
  let(:pager)       { described_class.new(source, page, per_page) }

  describe '#collection' do

    subject { pager.collection }

    it { is_expected.to eq ['MongoDB', 'Rails'] }

    describe 'last page' do
      let(:page) { 3 }
      it { is_expected.to eq ['Devise'] }
    end

    describe 'per_page is 1' do
      let(:per_page) { 1 }
      it { is_expected.to eq ['MongoDB'] }
    end

    describe 'per_page is > to the number of total entries' do
      let(:per_page) { 10 }
      it { is_expected.to eq ['MongoDB', 'Rails', 'Liquid', 'Rack', 'Devise'] }
    end

    describe 'page is > to the total number of pages' do
      let(:page) { 4 }
      it { is_expected.to eq [] }
    end

  end

  describe '#previous_page' do

    subject { pager.previous_page }

    it { is_expected.to eq nil }

    describe 'another page' do
      let(:page) { 2 }
      it { is_expected.to eq 1 }
    end

  end

  describe '#next_page' do

    subject { pager.next_page }

    it { is_expected.to eq 2 }

    describe 'another page' do
      let(:page) { 3 }
      it { is_expected.to eq nil }
    end

  end

  describe '#to_liquid' do

    subject { pager.to_liquid }

    it do
      is_expected.to eq({
        collection:       ['MongoDB', 'Rails'],
        current_page:     1,
        per_page:         2,
        previous_page:    nil,
        next_page:        2,
        total_entries:    5,
        total_pages:      3
      })
    end

  end

end
