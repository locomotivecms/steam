require 'spec_helper'

describe Locomotive::Steam::Liquid::Drops::Section do

  let(:context)     { ::Liquid::Context.new({}, {}, { locale: 'en' }) }
  let(:settings)    { [] }
  let(:definition)  { instance_double('SectionDefinition', definition: { 'settings' => settings }) }
  let(:drop)        { described_class.new(definition, content).tap { |d| d.context = context } }

  describe 'text type setting' do

    let(:settings) { [{ 'id' => 'title', 'type' => 'text' }] }
    let(:content) { { 'settings' => { 'title' => 'Hello world' } } }

    subject { drop.settings.before_method(:title) }

    it 'returns the value of the text setting' do
      is_expected.to eq 'Hello world'
    end

  end

end
