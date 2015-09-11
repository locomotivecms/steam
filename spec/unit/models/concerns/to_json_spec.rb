require 'spec_helper'

describe Locomotive::Steam::Models::Concerns::ToJson do

  let(:attributes) { {} }
  let(:entity) { SimpleEntity.new(attributes) }

  describe '#to_hash' do

    subject { entity.to_hash }

    it { expect(subject).to eq({}) }

    context 'simple attributes' do
      let(:attributes) { { title: 'Hello world', published: true, tags: ['a', 'b'] } }
      it { expect(subject).to eq('title' => 'Hello world', 'published' => true, 'tags' => ['a', 'b']) }
    end

    context 'localized attributes' do
      let(:attributes) { { title: Locomotive::Steam::Models::I18nField.new(:title, { fr: 'Bonjour', en: 'Hi' })} }
      it { expect(subject).to eq('title' => { 'fr' => 'Bonjour', 'en' => 'Hi' }) }
    end

    context 'referenced associations' do
      let(:attributes) { { title: 'Lorem ipsum', author: instance_double('BelongsToAssociation', repository: true) } }
      it { expect(subject).to eq('title' => 'Lorem ipsum') }
    end

  end

  describe '#as_json' do

    let(:options) { nil }

    subject { entity.as_json(options) }

    it { expect(subject).to eq({}) }

    context 'with options' do

      let(:options) { { only: ['title'] } }
      let(:attributes) { { title: 'Hello world', body: 'Lorem ipsum' } }

      it { expect(subject).to eq('title' => 'Hello world') }

    end

  end

  describe '#to_json' do

    subject { entity.to_json }

    it { expect(subject).to eq('{}') }

    context 'with attributes' do

      let(:attributes) { { title: 'Hello world', published: true } }

      it { expect(subject).to eq(%{{"title":"Hello world","published":true}}) }

    end

  end

  class SimpleEntity
    include Locomotive::Steam::Models::Concerns::ToJson
    attr_reader :attributes
    def initialize(attributes = {}); @attributes = attributes; end
  end

end
