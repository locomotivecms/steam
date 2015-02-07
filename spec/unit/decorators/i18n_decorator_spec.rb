require 'spec_helper'

describe Locomotive::Steam::Decorators::I18nDecorator do

  let(:page)            { instance_double('Page', title: 'Hello world', published?: true, attributes: { title: { en: 'Hello world!', fr: 'Bonjour monde' } }) }
  let(:translated)      { [:title] }
  let(:locale)          { 'fr' }
  let(:default_locale)  { nil }
  let(:decorated)       { Locomotive::Steam::Decorators::I18nDecorator.new(page, translated, locale, default_locale) }

  it 'uses the translated version of the title attribute' do
    expect(decorated.title).to eq 'Bonjour monde'
  end

  it 'allows access to the other methods of the model too' do
    expect(decorated.published?).to eq true
  end

  describe 'no translated attributes: use the default method' do

    let(:translated) { [] }
    it { expect(decorated.title).to eq 'Hello world' }

  end

  describe 'using a different locale' do

    before { decorated.__locale__ = 'en' }
    it { expect(decorated.title).to eq 'Hello world!' }
    it { expect(decorated.published?).to eq true }

  end

  describe 'using the default locale' do

    let(:locale)          { 'de' }
    let(:default_locale)  { 'en' }
    it { expect(decorated.title).to eq 'Hello world!' }

  end

  it 'uses another way to switch to a different locale' do
    decorated.__with_locale__(:en) do
      expect(decorated.title).to eq 'Hello world!'
    end
    expect(decorated.__locale__).to eq :fr
  end

end
