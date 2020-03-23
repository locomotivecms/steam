require 'spec_helper'

describe Locomotive::Steam::Liquid::Drops::Section do

  let(:context)           { ::Liquid::Context.new({}, {}, { locale: 'en' }) }
  let(:settings)          { [] }
  let(:definition)        { instance_double('SectionDefinition', definition: { 'settings' => settings, 'blocks' => block_definitions }) }
  let(:block_definitions) { [] }
  let(:drop)              { described_class.new(definition, content).tap { |d| d.context = context } }

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

  describe 'blocks_as_tree' do

    let(:block_definitions) { [{ 'type' => 'page' }] }
    let(:content) { { 'blocks' => [
      { 'id' => '1', 'type' => 'page', 'settings' => { 'name' => 'Page 1' } },
      { 'id' => '2', 'type' => 'page', 'settings' => { 'name' => 'Page 2' } },
      { 'id' => '2.1', 'type' => 'page', 'depth' => 1, 'settings' => { 'name' => 'Page 2.1' } },
      { 'id' => '2.2', 'type' => 'page', 'depth' => 1, 'settings' => { 'name' => 'Page 2.2' } },
      { 'id' => '2.2.1', 'type' => 'page', 'depth' => 2, 'settings' => { 'name' => 'Page 2.2.1' } },
      { 'id' => '2.2.2', 'type' => 'page', 'depth' => 2, 'settings' => { 'name' => 'Page 2.2.2' } },
      { 'id' => '2.2.2.1', 'type' => 'page', 'depth' => 3, 'settings' => { 'name' => 'Page 2.2.2.1' } },
      { 'id' => '2.3', 'type' => 'page', 'depth' => 1, 'settings' => { 'name' => 'Page 2.3' } },
      { 'id' => '3', 'type' => 'page', 'depth' => 0, 'settings' => { 'name' => 'Page 3' } },
    ] } }

    subject { drop.blocks_as_tree }

    it 'represents the blocks as a tree (node + leaves)' do
      expect(subject.map { |drop| drop.id }).to eq(%w(1 2 3))
      expect(subject[1].leaves.map { |drop| drop.id }).to eq(%w(2.1 2.2 2.3))
      expect(subject[1].leaves[1].leaves.map { |drop| drop.id }).to eq(%w(2.2.1 2.2.2))
      expect(subject[1].leaves[1].leaves[1].leaves.map { |drop| drop.id }).to eq(%w(2.2.2.1))
    end

  end

end
