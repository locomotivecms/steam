require 'spec_helper'

describe Locomotive::Steam::Liquid::Drops::Page do

  let(:assigns)   { {} }
  let(:services)  { Locomotive::Steam::Services.build_instance }
  let(:site)      { instance_double('Site', default_locale: 'en') }
  let(:context)   { ::Liquid::Context.new(assigns, {}, { locale: 'en', services: services, site: site }) }
  let(:page)      { instance_double('Page', id: 42, localized_attributes: [], title: 'Index', slug: 'index', fullpath: 'index', content_type: nil, depth: 1, templatized?: false, listed?: true, published?: true, is_layout?: true, redirect?: false, seo_title: 'seo title', redirect_url: '/', handle: 'index', meta_keywords: 'keywords', meta_description: 'description') }
  let(:drop)      { described_class.new(page).tap { |d| d.context = context } }

  subject { drop }

  it 'gives access to general attributes' do
    expect(subject.id).to eq 42
    expect(subject.title).to eq 'Index'
    expect(subject.original_title).to eq 'Index'
    expect(subject.slug).to eq 'index'
    expect(subject.original_slug).to eq 'index'
    expect(subject.fullpath).to eq 'index'
    expect(subject.content_type).to eq nil
    expect(subject.depth).to eq 1
    expect(subject.redirect_url).to eq '/'
    expect(subject.handle).to eq 'index'
    expect(subject.seo_title).to eq 'seo title'
    expect(subject.meta_keywords).to eq 'keywords'
    expect(subject.meta_description).to eq 'description'
    expect(subject.listed?).to eq true
    expect(subject.redirect?).to eq false
    expect(subject.is_layout?).to eq true
    expect(subject.published?).to eq true
    expect(subject.templatized?).to eq false
  end

  describe '#parent' do

    let(:parent) { instance_double('ParentPage', to_liquid: { 'title' => 'Parent' }) }

    before do
      allow(services.repositories.page).to receive(:parent_of).with(page).and_return(parent)
    end

    it { expect(subject.parent).to eq({ 'title' => 'Parent' }) }

  end

  describe '#breadcrumbs' do

    let(:ancestors) { [instance_double('ParentPage', to_liquid: { 'title' => 'Parent' })] }

    before do
      allow(services.repositories.page).to receive(:ancestors_of).with(page).and_return(ancestors)
    end

    it { expect(subject.breadcrumbs).to eq([{ 'title' => 'Parent' }]) }

  end

   describe '#children' do

    let(:children) { [instance_double('ChildPage', to_liquid: { 'title' => 'Child' })] }

    before do
      allow(services.repositories.page).to receive(:children_of).with(page).and_return(children)
    end

    it { expect(subject.children).to eq([{ 'title' => 'Child' }]) }

  end

  describe '#editable_elements' do

    let(:elements) { [instance_double('EditableElement', block: 'top/left', slug: 'banner', content: 'Hello world', localized_attributes: [])] }

    before do
      allow(services.repositories.page).to receive(:editable_elements_of).with(page).and_return(elements)
    end

    it { expect(subject.editable_elements).to eq({ 'top' => { 'left' => { 'banner' => 'Hello world' } } }) }

  end

  context 'templatized page' do

    let(:entry)   { liquid_instance_double('ContentEntry', _label: 'First Article', _slug: 'first-article') }
    let(:assigns) { { 'entry' => entry } }
    let(:page)    { instance_double('Page', id: 42, title: 'Index', slug: 'index', localized_attributes: [], templatized?: true, content_type_id: 42) }

    it { expect(subject.title).to eq 'First Article' }
    it { expect(subject.slug).to eq 'first-article' }

    describe '#content_type' do

      before do
        allow(services.repositories.content_type).to receive(:find).with(42).and_return('Articles')
      end

      it { expect(subject.content_type).not_to eq nil }

    end

  end

  describe 'i18n' do

    let(:page) { instance_double('Page', title: { en: 'About us', fr: 'A notre sujet' }, templatized?: false, localized_attributes: { title: true }) }
    let(:drop) { described_class.new(page).tap { |d| d.context = context } }

    it { expect(subject.title).to eq 'About us' }

    context 'change the current locale of the context' do

      let(:context) { ::Liquid::Context.new(assigns, {}, { locale: 'fr', site: site }) }
      it { expect(subject.title).to eq 'A notre sujet' }

    end

    context 'change the locale down the road' do

      before { subject.send(:_change_locale, 'fr') }
      it { expect(subject.title).to eq 'A notre sujet' }

    end

    it 'prevents further modifications of the locale' do
      subject.send(:_change_locale!, 'fr')
      expect(subject.title).to eq 'A notre sujet'
      subject.send(:_change_locale, 'en')
      expect(subject.title).to eq 'A notre sujet'
    end

  end

end
