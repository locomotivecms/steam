require 'spec_helper'

describe Locomotive::Steam::Liquid::Drops::ContentTypeProxyCollection do

  let(:assigns)       { {} }
  let(:content_type)  { instance_double('ContentType', slug: 'articles') }
  let(:services)      { Locomotive::Steam::Services.build_instance }
  let(:context)       { ::Liquid::Context.new(assigns, {}, { services: services }) }
  let(:drop)          { described_class.new(content_type).tap { |d| d.context = context } }

  describe '#public_submission_url' do
    it { expect(drop.public_submission_url).to eq '/entry_submissions/articles' }
  end

  describe '#api' do
    it { expect(drop.api).to eq({ 'create' => '/entry_submissions/articles' }) }
  end

  describe 'acts as a collection' do

    before do
      allow(services.repositories.content_entry).to receive(:all).with(nil).and_return(['a', 'b'])
    end

    describe '#first' do
      it { expect(drop.first).to eq('a') }
    end

    describe '#last' do
      it { expect(drop.last).to eq('b') }
    end

    describe '#count' do
      it { expect(drop.count).to eq 2 }
    end

    context 'with a scope' do

      let(:assigns) { { 'with_scope' => { 'visible' => true } } }

      before do
        expect(services.repositories.content_entry).to receive(:all).with({ 'visible' => true }).and_return(['a', 'b'])
      end

      describe '#first' do
        it { expect(drop.first).to eq('a') }
      end

      describe '#count' do
        it { expect(drop.count).to eq 2 }
      end

    end

  end

  describe 'get options of a select field' do

    before do
      expect(services.repositories.content_type).to receive(:select_options).with(content_type, 'category').and_return(['a', 'b'])
    end

    it { expect(drop.before_method(:category_options)).to eq ['a', 'b'] }

  end

  describe 'group entries by a select/belongs_to field' do

    before do
      expect(services.repositories.content_entry).to receive(:group_by_select_option).with(content_type, 'category').and_return([['a', [1, 2]]])
    end

    it { expect(drop.before_method(:group_by_category)).to eq [['a', [1, 2]]] }

  end

  describe 'unknown method' do

    it { expect(drop.before_method(:foo)).to eq nil }

  end

end
