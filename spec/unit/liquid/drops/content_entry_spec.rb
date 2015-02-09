require 'spec_helper'

describe Locomotive::Steam::Liquid::Drops::ContentEntry do

  let(:site)      { instance_double('Site', default_locale: 'en') }
  let(:entry)     { instance_double('Article', _id: 42, title: 'Hello world', _label: 'Hello world', _slug: 'hello-world', _translated: false, seo_title: 'seo title', meta_keywords: 'keywords', meta_description: 'description') }
  let(:assigns)   { {} }
  let(:services)  { Locomotive::Steam::Services.build_instance }
  let(:context)   { ::Liquid::Context.new(assigns, {}, { services: services, site: site, locale: 'en' }) }
  let(:drop)      { Locomotive::Steam::Liquid::Drops::ContentEntry.new(entry).tap { |d| d.context = context } }

  subject { drop }

  it 'gives access to general attributes' do
    expect(subject._id).to eq '42'
    expect(subject._label).to eq 'Hello world'
    expect(subject._slug).to eq 'hello-world'
    expect(subject._permalink).to eq 'hello-world'
    expect(subject.seo_title).to eq 'seo title'
    expect(subject.meta_keywords).to eq 'keywords'
    expect(subject.meta_description).to eq 'description'
  end

  describe '#before_method (dynamic attributes)' do

    describe 'simple ones' do
      it { expect(subject.before_method(:title)).to eq 'Hello world' }
    end

    describe 'relationship field' do

      let(:authors) { instance_double('Authors', all: ['john', 'jane']) }
      let(:entry)   { instance_double('Article', authors: authors) }

      before do
        allow(services.repositories.content_entry).to receive(:filter).with(authors, {}).and_return(authors.all)
      end

      it { expect(subject.before_method(:authors).first).to eq 'john' }

    end

  end

  describe '#next' do

    let(:next_entry) { instance_double('NextEntry', to_liquid: true) }

    before do
      expect(services.repositories.content_entry).to receive(:next).with(entry).and_return(next_entry)
    end

    it { expect(subject.next).to eq true }

  end

  describe '#previous' do

    let(:previous_entry) { instance_double('PreviousEntry', to_liquid: true) }

    before do
      expect(services.repositories.content_entry).to receive(:previous).with(entry).and_return(previous_entry)
    end

    it { expect(subject.previous).to eq true }

  end

  describe '#errors' do

    let(:errors) { instance_double('Errors', messages: { title: ['not_blank'] }) }

    before do
      expect(entry).to receive(:errors).and_return(errors)
    end

    it { expect(subject.errors).to eq('title' => ['not_blank']) }

  end

  describe 'i18n' do

    let(:entry) { instance_double('Article', attributes: { title: { en: 'Hello world', fr: 'Bonjour monde' } }) }
    let(:drop)  { Locomotive::Steam::Liquid::Drops::ContentEntry.new(entry, [:title]).tap { |d| d.context = context } }

    subject { drop.before_method(:title) }

    it { is_expected.to eq 'Hello world' }

    context 'change the current locale of the context' do

      let(:context) { ::Liquid::Context.new(assigns, {}, { locale: 'fr', site: site }) }
      it { is_expected.to eq 'Bonjour monde' }

    end

  end

end
