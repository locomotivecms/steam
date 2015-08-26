require 'spec_helper'

describe Locomotive::Steam::Liquid::Tags::PathTo do

  let(:assigns)   { {} }
  let(:services)  { Locomotive::Steam::Services.build_instance }
  let(:site)      { instance_double('Site', locales: ['en'], default_locale: 'en') }
  let(:context)   { ::Liquid::Context.new(assigns, {}, { services: services, site: site, locale: 'en' }) }

  subject { render_template(source, context) }

  before { allow(services).to receive(:current_site).and_return(site) }

  describe 'parsing' do

    let(:source) { '{% path_to %}' }
    it { expect { subject }.to raise_error('Valid syntax: path_to <page|page_handle|content_entry>(, locale: [fr|de|...], with: <page_handle>') }

  end

  describe 'unknown page' do

    let(:source) { '{% path_to index %}' }

    before do
      expect(services.page_finder).to receive(:by_handle).with('index').and_return(nil)
    end

    it { is_expected.to eq '' }

  end

  describe 'from a handle of a page' do

    let(:drop)      { Locomotive::Steam::Liquid::Drops::Page.new(page) }
    let(:page)      { liquid_instance_double('Index', title: 'Index', handle: 'index', fullpath: fullpath, localized_attributes: { fullpath: true }, templatized?: false) }
    let(:fullpath)  { { en: 'index', fr: 'index' } }
    let(:source)    { '{% path_to index %}' }

    before do
      expect(services.page_finder).to receive(:by_handle).with('index').and_return(page)
      allow(page).to receive(:to_liquid).and_return(drop)
    end

    it { is_expected.to eq '/' }

    context 'and a different locale' do

      let(:source) { "{% path_to index, locale: 'fr' %}" }
      it { is_expected.to eq '/fr' }

    end

  end

  describe 'from a page (drop) itself' do

    let(:assigns)   { { 'about_us' => drop } }
    let(:drop)      { Locomotive::Steam::Liquid::Drops::Page.new(page) }
    let(:page)      { liquid_instance_double('AboutUs', title: 'About us', handle: 'index', localized_attributes: { fullpath: true }, fullpath: fullpath, localized_attributes: [:fullpath], templatized?: false) }
    let(:fullpath)  { { en: 'about-us', fr: 'a-notre-sujet' } }
    let(:source)    { '{% path_to about_us %}' }

    it { is_expected.to eq '/about-us' }

    context 'and a different locale' do

      let(:source) { "{% path_to about_us, locale: 'fr' %}" }
      it { is_expected.to eq '/fr/a-notre-sujet' }

    end

  end

  describe 'from a content entry (drop)' do

    let(:assigns)     { { 'article' => entry_drop } }
    let(:entry_drop)  { Locomotive::Steam::Liquid::Drops::ContentEntry.new(entry) }
    let(:entry)       { liquid_instance_double('Article', localized_attributes: { _slug: true }, _slug: { en: 'hello-world', fr: 'bonjour-monde' }) }
    let(:drop)        { Locomotive::Steam::Liquid::Drops::Page.new(page) }
    let(:page)        { liquid_instance_double('ArticleTemplate', title: 'Template of an article', handle: 'article', localized_attributes: { fullpath: true }, fullpath: { en: 'my-articles/content_type_template', fr: 'mes-articles/content_type_template' }, content_entry: entry_drop.send(:_source), templatized?: true) }
    let(:source)      { '{% path_to article %}' }

    before do
      expect(services.repositories.page).to receive(:template_for).with(entry, nil).and_return(page)
      allow(page).to receive(:to_liquid).and_return(drop)
    end

    it { is_expected.to eq '/my-articles/hello-world' }

    context 'and a different locale' do

      let(:source) { "{% path_to article, locale: 'fr' %}" }
      it { is_expected.to eq '/fr/mes-articles/bonjour-monde' }

    end

  end

end
