require 'spec_helper'

describe Locomotive::Steam::Liquid::Tags::Extends do

  let(:source)      { '{% extends parent %} ' }
  let(:page)        { instance_double('Page', title: 'About us') }
  let(:site)        { instance_double('Site', default_locale: :en) }
  let!(:listener)   { Liquid::SimpleEventsListener.new }
  let(:finder)      { Locomotive::Steam::ParentFinderService.new(instance_double('PageRepository', site: site, locale: :en)) }
  let(:parser)      { Locomotive::Steam::LiquidParserService.new(nil, nil) }
  let(:options)     { { parent_finder: finder, page: page, parser: parser } }

  before do
    expect(finder.repository).to receive(:parent_of).with(page).and_return(parent)
  end

  describe 'no parent page found' do

    let(:parent)    { nil }
    let(:template)  { parse_template(source, options) }

    it { expect { template }.to raise_exception Locomotive::Steam::Liquid::PageNotFound }

  end

  describe 'parent page exists' do

    let!(:template) { parse_template(source, options) }

    let(:parent) { instance_double('Index', handle: nil, slug: nil, localized_attributes: { source: true, template: true }, source: { en: 'Hello world!' }, template: { en: nil }) }

    it { expect(listener.event_names.first).to eq 'steam.parse.extends' }
    it { expect(template.render).to eq 'Hello world!' }
    it { expect(options[:page]).to eq page }

    describe 'set the layout name' do

      let(:source) { '{% extends parent %}{% block message %}My layout: {{ layout_name }}{% endblock %}' }

      let(:parent) { instance_double('Index', handle: nil, slug: 'index', localized_attributes: { source: true, template: true }, source: { en: 'Hello world! {% block message %}{% endblock %}' }, template: { en: nil }) }

      it { expect(template.render).to eq 'Hello world! My layout: index' }

      context 'the handle of the parent page exists' do

        let(:parent) { instance_double('Index', handle: 'home', slug: 'index', localized_attributes: { source: true, template: true }, source: { en: 'Hello world! {% block message %}{% endblock %}' }, template: { en: nil }) }

        it { expect(template.render).to eq 'Hello world! My layout: home' }

      end

    end

  end

end
