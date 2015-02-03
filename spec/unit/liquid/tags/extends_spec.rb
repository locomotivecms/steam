require 'spec_helper'

describe Locomotive::Steam::Liquid::Tags::Extends do

  let(:source)      { '{% extends parent %} ' }
  let(:page)        { instance_double('Page', title: 'About us') }
  let(:listener)    { Liquid::SimpleEventsListener.new }
  let(:finder)      { Locomotive::Steam::Services::ParentFinder.new(nil) }
  let(:options)     { { events_listener: listener, parent_finder: finder, page: page } }

  before do
    allow(finder.repository).to receive(:parent_of).and_return(parent)
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
      let(:parent)          { instance_double('Index', template: parent_template) }

      it { expect(listener.event_names.first).to eq :extends }
      it { expect(template.render).to eq 'Hello world' }
      it { expect(options[:page]).to eq page }

    end

    describe 'parent template not parsed yet' do

      let(:parent) { instance_double('Index', source: 'Hello world!', template: nil) }

      it { expect(listener.event_names.first).to eq :extends }
      it { expect(template.render).to eq 'Hello world!' }
      it { expect(options[:page]).to eq page }

    end

  end

end
