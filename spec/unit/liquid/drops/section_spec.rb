require 'spec_helper'

describe Locomotive::Steam::Liquid::Drops::Section do

  let(:context)     { ::Liquid::Context.new({}, {}, { locale: 'en' }) }
  let(:settings)    { [] }
  let(:definition)  { instance_double('SectionDefinition', definition: { 'settings' => settings }) }
  let(:drop)        { described_class.new(definition, content).tap { |d| d.context = context } }

  describe 'text type setting' do

    let(:url_finder) { instance_double('UrlFinder', decode_urls_for: 'Hello world') }
    let(:settings) { [{ 'id' => 'title', 'type' => 'text' }] }
    let(:content) { { 'settings' => { 'title' => 'Hello world' } } }

    before { expect(drop.settings).to receive(:url_finder).and_return(url_finder) }

    subject { drop.settings.liquid_method_missing(:title) }

    it 'returns the value of the text setting' do
      is_expected.to eq 'Hello world'
    end

  end

end
