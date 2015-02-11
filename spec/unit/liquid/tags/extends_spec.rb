require 'spec_helper'

describe Locomotive::Steam::Liquid::Tags::Extends do

  let(:source)      { '{% extends parent %} ' }
  let(:page)        { instance_double('Page', title: 'About us') }
  let(:site)        { instance_double('Site', default_locale: :en) }
  let(:listener)    { Liquid::SimpleEventsListener.new }
  let(:finder)      { Locomotive::Steam::Services::ParentFinder.new(instance_double('PageRepository', site: site, current_locale: :en)) }
  let(:parser)      { Locomotive::Steam::Services::LiquidParser.new }
  let(:options)     { { events_listener: listener, parent_finder: finder, page: page, parser: parser } }

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

    describe 'parent template already parsed' do

      let(:parent_template) { parse_template('Hello world') }
      let(:parent)          { instance_double('Index', attributes: { template: { en: parent_template } }, localized_attributes: [:template]) }

      it { expect(listener.event_names.first).to eq :extends }
      it { expect(template.render).to eq 'Hello world' }
      it { expect(options[:page]).to eq page }

    end

    describe 'parent template not parsed yet' do

      let(:parent) { instance_double('Index', attributes: { source: { en: 'Hello world!' }, template: { en: nil } }, localized_attributes: [:template, :source]) }

      it { expect(listener.event_names.first).to eq :extends }
      it { expect(template.render).to eq 'Hello world!' }
      it { expect(options[:page]).to eq page }

    end

  end

end
