require 'spec_helper'

describe Locomotive::Steam::Decorators::I18nDecorator do

  let(:field)           { i18n_field(:title, { en: 'Hello world!', fr: 'Bonjour monde' }) }
  let(:other_field)     { i18n_field(:slug, 'hello-world') }
  let(:page)            { instance_double('Page', published?: true, title: field, slug: other_field) }
  let(:locale)          { 'fr' }
  let(:default_locale)  { nil }
  let(:decorated)       { described_class.new(page, locale, default_locale) }

  it 'uses the localized version of the title attribute' do
    expect(decorated.title).to eq 'Bonjour monde'
  end

  it 'uses the same value for all the locales' do
    expect(decorated.slug).to eq 'hello-world'
  end

  it 'allows access to the other methods of the model too' do
    expect(decorated.published?).to eq true
  end

  it 'allows to set a new value' do
    decorated.title = 'Bonjour le monde'
    expect(decorated.title).to eq 'Bonjour le monde'
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

  describe 'freeze locale' do

    before { decorated.__freeze_locale__ }

    it 'forbids the modification of the locale' do
      decorated.__locale__ = 'en'
      expect(decorated.title).to eq 'Bonjour monde'
    end

  end

  it 'uses another way to switch to a different locale' do
    decorated.__with_locale__(:en) do
      expect(decorated.title).to eq 'Hello world!'
    end
    expect(decorated.__locale__).to eq :fr
  end

  def i18n_field(name, translations)
    Locomotive::Steam::Models::I18nField.new(name, translations)
  end

  # describe 'with a model' do

  #   let(:model)     { Locomotive::Steam::Site.new(name: 'Acme') }
  #   let(:decorated) { Locomotive::Steam::Decorators::I18nDecorator.new(model, nil, locale, default_locale) }

  #   it 'runs some basic tests' do
  #     pending
  #     # expect(model.localized_attributes).to eq [:seo_title, :meta_description, :meta_keywords]
  #     # expect(model.class.localized_attributes).to eq [:seo_title, :meta_description, :meta_keywords]
  #     # expect(decorated.name).to eq 'Acme'
  #     # expect(decorated.meta_description).to eq nil
  #   end

  # end

end
