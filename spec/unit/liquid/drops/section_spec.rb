require 'spec_helper'

describe Locomotive::Steam::Liquid::Drops::Section do

  let(:context) { ::Liquid::Context.new({}, {}, { locale: 'en' }) }
  let(:settings) { [] }
  let(:definition) { 
    instance_double('SectionDefinition', definition: { 
      'settings' => settings, 
      'blocks' => [{type: :foo}, {type: :bar}], 
    })
  }
  let(:content) {
    {
      'settings' => {},
      'blocks' => [
        {'type' => 'foo'}, 
        {'type' => 'bar'}, 
        {'type' => 'foo'},
      ]
    }
  }
  let(:drop) { described_class.new(definition, content).tap { |d| d.context = context } }

  describe 'text type setting' do

    let(:url_finder) { instance_double('UrlFinder', decode_urls_for: 'Hello world') }
    let(:settings) { [{ 'id' => 'title', 'type' => 'text' }] }
    let(:content) { { 'settings' => { 'title' => 'Hello world' } } }

    before { expect(drop.settings).to receive(:url_finder).and_return(url_finder) }

    subject { drop.settings.before_method(:title) }

    it 'returns the value of the text setting' do
      is_expected.to eq 'Hello world'
    end

  end

  describe '#blocks' do
    subject { drop.send(:blocks).count }

    before { context['with_scope'] = {'type' => 'foo'} }

    it { is_expected.to eq 2 }

    context 'the with_scope has been used before by another and different content type' do
      before { context['with_scope_content_type'] = 'articles' }
      it { is_expected.to eq 3 }
    end

    context 'the with_scope has been used before by the same content type' do
      before { context['with_scope_content_type'] = 'blocks' }
      it { is_expected.to eq 2 }
    end

  end


end
