require 'spec_helper'

describe Locomotive::Steam::Liquid::Drops::ContentEntryCollection do

  let(:assigns)       { {} }
  let(:content_type)  { instance_double('ContentType', slug: 'articles') }
  let(:services)      { Locomotive::Steam::Services.build_instance }
  let(:context)       { ::Liquid::Context.new(assigns, {}, { services: services, locale: :en }) }
  let(:drop)          { described_class.new(content_type).tap { |d| d.context = context } }

  before { allow(services).to receive(:current_site).and_return(nil) }

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

    describe '#last' do
      it { expect(drop.map(&:to_s)).to eq(['a', 'b']) }
    end

    context 'with a scope' do

      let(:assigns) { { 'with_scope' => { 'visible' => true } } }

      describe '#first' do
        before do
          expect(services.repositories.content_entry).to receive(:all).with('visible' => true).and_return(['a', 'b'])
        end
        it { expect(drop.first).to eq('a') }
      end

      describe '#count' do
        before do
          expect(services.repositories.content_entry).to receive(:count).with('visible' => true).and_return(2)
        end
        it { expect(drop.count).to eq 2 }
      end

      describe 'only applied to the first content type' do

        it 'sets the content type in the context' do
          expect(services.repositories.content_entry).to receive(:all).with('visible' => true).and_return(['a', 'b'])
          expect(context['with_scope_content_type']).to eq nil
          drop.first
          expect(context['with_scope_content_type']).to eq 'articles'
        end

        it "doesn't apply the with_scope conditions if it's not the same content type" do
          context['with_scope_content_type'] = 'projects'
          expect(services.repositories.content_entry).to receive(:all).with({}).and_return(['a', 'b'])
          drop.first
          expect(context['with_scope_content_type']).to eq 'projects'
        end

      end

    end

  end

  describe 'get options of a select field' do

    let(:option_a) { build_select_option(en: 'a') }
    let(:option_b) { build_select_option('b') }

    before do
      expect(services.repositories.content_type).to receive(:select_options).with(content_type, 'category').and_return([option_a, option_b])
    end

    it { expect(drop.liquid_method_missing(:category_options)).to eq ['a', 'b'] }

  end

  describe 'group entries by a select/belongs_to field' do

    before do
      expect(services.repositories.content_entry).to receive(:group_by_select_option).with('category').and_return([['a', [1, 2]]])
    end

    it { expect(drop.liquid_method_missing(:group_by_category)).to eq [['a', [1, 2]]] }

  end

  describe 'unknown method' do

    it { expect(drop.liquid_method_missing(:foo)).to eq nil }

  end

  def build_select_option(name)
    _name = Locomotive::Steam::Models::I18nField.new('name', name)
    Locomotive::Steam::ContentTypeField::SelectOption.new(name: _name).tap do |option|
      option.localized_attributes = [:name]
    end
  end

end
