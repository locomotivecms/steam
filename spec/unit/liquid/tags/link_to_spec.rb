require 'spec_helper'

describe Locomotive::Steam::Liquid::Tags::PathTo do

  let(:assigns)   { {} }
  let(:services)  { Locomotive::Steam::Services.build_instance }
  let(:site)      { instance_double('Site', default_locale: 'en') }
  let(:context)   { ::Liquid::Context.new(assigns, {}, { services: services, site: site, locale: 'en' }) }

  subject { render_template(source, context) }

  before { allow(services).to receive(:current_site).and_return(site) }

  describe 'parsing' do

    let(:source) { '{% link_to %}' }
    it { expect { subject }.to raise_error("Syntax Error in 'link_to' - Valid syntax: link_to page_handle, locale es (locale is optional)") }

    context 'unknown tag' do

      let(:source) { '{% link_to index %}{% endbar %}{% endlink_to %}' }
      it { expect { subject }.to raise_error("Liquid syntax error: Unknown tag 'endbar'") }

    end

  end

  describe 'unknown page' do

    let(:source) { '{% link_to index %}' }

    before do
      expect(services.repositories.page).to receive(:by_handle).with('index').and_return(nil)
    end

    it { is_expected.to eq '' }

  end

  describe '#render' do

    let(:drop)      { Locomotive::Steam::Liquid::Drops::Page.new(page, [:title, :fullpath]) }
    let(:page)      { liquid_instance_double('Index', handle: 'index', attributes: { title: { en: 'Home', fr: 'Accueil' }, fullpath: fullpath }, templatized?: false) }
    let(:fullpath)  { { en: 'index', fr: 'index' } }

    before do
      allow(services.repositories.page).to receive(:by_handle).with('index').and_return(page)
      allow(page).to receive(:to_liquid).and_return(drop)
    end

    describe 'used as a tag' do

      let(:source) { 'My link: {% link_to index %}!' }
      it { is_expected.to eq 'My link: <a href="/">Home</a>!' }

      context 'and a different locale' do

        let(:source) { "{% link_to index, locale: 'fr' %}" }
        it { is_expected.to eq '<a href="/fr">Accueil</a>' }

      end

      context 'inside another block' do

        let(:source) { '{% block header %}My links: {% link_to index %} & {% link_to index %}here too{% endlink_to %}{% endblock %}' }
        it { is_expected.to eq 'My links: <a href="/">Home</a> & <a href="/">here too</a>' }

      end

    end

    describe 'used as a block' do

      let(:source)    { 'My link: {% link_to index %}click here{% endlink_to %}!' }
      it { is_expected.to eq 'My link: <a href="/">click here</a>!' }

      context 'and a different locale' do

        let(:source) { "{% link_to index, locale: 'fr' %}{{ target.title }}!{% endlink_to %}" }
        it { is_expected.to eq '<a href="/fr">Accueil!</a>' }

      end

    end

    describe 'link to a content entry (drop)' do

      let(:assigns)     { { 'article' => entry_drop } }
      let(:entry_drop)  { Locomotive::Steam::Liquid::Drops::ContentEntry.new(entry, [:_label, :_slug]) }
      let(:entry)       { liquid_instance_double('Article', attributes: { _label: { en: 'Hello world', fr: 'Bonjour monde' }, _slug: { en: 'hello-world', fr: 'bonjour-monde' } }) }
      let(:drop)        { Locomotive::Steam::Liquid::Drops::Page.new(page, [:fullpath]) }
      let(:page)        { liquid_instance_double('ArticleTemplate', title: 'Template of an article', handle: 'article', attributes: { fullpath: { en: 'my-articles/content-type-template', fr: 'mes-articles/content-type-template' } }, localized_attributes: [:fullpath], content_entry: entry_drop.send(:_source), templatized?: true) }
      let(:source)      { '{% link_to article %}' }

      before do
        expect(services.repositories.page).to receive(:template_for).with(entry, nil).and_return(page)
      end

      it { is_expected.to eq '<a href="/my-articles/hello-world">Hello world</a>' }

      context 'with a different locale' do

        let(:source) { "{% link_to article, locale: 'fr' %}" }
        it { is_expected.to eq '<a href="/fr/mes-articles/bonjour-monde">Bonjour monde</a>' }

      end

    end

  end

end
