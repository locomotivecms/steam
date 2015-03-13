require 'spec_helper'

describe Locomotive::Steam::Liquid::Tags::LocaleSwitcher do

  let(:locale)      { 'en' }
  let(:assigns)     { { 'page' => drop } }
  let(:services)    { Locomotive::Steam::Services.build_instance }
  let(:site)        { instance_double('Site', locales: %w(en fr), default_locale: 'en') }
  let(:drop)        { Locomotive::Steam::Liquid::Drops::Page.new(page) }
  let(:page)        { liquid_instance_double('Index', localized_attributes: { title: true, fullpath: true }, title: { en: 'Home', fr: 'Accueil' }, fullpath: { en: 'index', fr: 'index' }, templatized?: false) }
  let(:context)     { ::Liquid::Context.new(assigns, {}, { services: services, site: site, locale: locale }) }

  subject { render_template(source, context) }

  before { allow(services).to receive(:current_site).and_return(site) }

  describe 'default rendering' do

    let(:source) { '{% locale_switcher %}' }
    it { is_expected.to eq '<div id="locale-switcher"><a href="/" class="en current">en</a> | <a href="/fr" class="fr">fr</a></div>' }

    context 'different current locale' do

      let(:locale) { 'fr' }
      it { is_expected.to eq '<div id="locale-switcher"><a href="/" class="en">en</a> | <a href="/fr" class="fr current">fr</a></div>' }

    end

  end

  describe 'using the locale to display the links' do

    let(:source) { '{% locale_switcher label: "locale", sep: " - " %}' }
    it { is_expected.to eq '<div id="locale-switcher"><a href="/" class="en current">English</a> - <a href="/fr" class="fr">French</a></div>' }

  end

  describe 'using the title of the page to display the links' do

    let(:source) { '{% locale_switcher label: "title" %}' }
    it { is_expected.to eq '<div id="locale-switcher"><a href="/" class="en current">Home</a> | <a href="/fr" class="fr">Accueil</a></div>' }

  end

  describe 'the page is templatized' do

    let(:assigns)     { { 'article' => entry_drop, 'page' => drop } }
    let(:entry_drop)  { Locomotive::Steam::Liquid::Drops::ContentEntry.new(entry) }
    let(:entry)       { liquid_instance_double('Article', _label: { en: 'Hello world', fr: 'Bonjour monde' }, _slug: { en: 'hello-world', fr: 'bonjour-monde' }, localized_attributes: { _label: true, _slug: true }) }
    let(:drop)        { Locomotive::Steam::Liquid::Drops::Page.new(page) }
    let(:page)        { liquid_instance_double('ArticleTemplate', title: 'Article template', fullpath: { en: 'my-articles/content_type_template', fr: 'mes-articles/content_type_template' }, content_entry: entry_drop.send(:_source), templatized?: true, localized_attributes: { fullpath: true }) }

    let(:source) { '{% locale_switcher label: "title" %}' }
    it { is_expected.to eq '<div id="locale-switcher"><a href="/my-articles/hello-world" class="en current">Hello world</a> | <a href="/fr/mes-articles/bonjour-monde" class="fr">Bonjour monde</a></div>' }

  end

end
