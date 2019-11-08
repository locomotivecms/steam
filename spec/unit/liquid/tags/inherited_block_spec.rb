require 'spec_helper'

describe Locomotive::Steam::Liquid::Tags::InheritedBlock do

  let(:parent_source) { 'My product: {% block product %}Random{% endblock %}' }
  let(:parent)        { instance_double('Index', liquid_source: parent_source, template: nil, :template= => nil, slug: nil, handle: nil) }
  let(:source)        { '{% extends parent %}{% block product %}Skis{% endblock %}' }
  let(:page)          { instance_double('Page') }

  let!(:listener)     { Liquid::SimpleEventsListener.new }
  let(:finder)        { instance_double('Finder', find: parent) }
  let(:options)       { { page: page, parent_finder: finder, parser: Locomotive::Steam::LiquidParserService.new(nil, nil) } }

  subject { parse_template(source, options) }

  describe 'wrong syntax' do

    let(:source) { '{% extends parent %}{% block %}Hello world{% endblock %}' }
    it { expect { subject }.to raise_exception(Liquid::SyntaxError) }
  end

  describe 'without a super block' do

    before { subject }

    it { expect(listener.events.size).to eq 3 }
    it { expect(listener.events.first.last[:found_super]).to eq false }
    it { expect(subject.render).to eq 'My product: Skis' }

  end

  describe 'with a super block' do

    before { subject }

    let(:source) { '{% extends parent %}{% block product %}Skis (previous: {{ block.super }}){% endblock %}' }

    it { expect(listener.events.first.last[:found_super]).to eq true }
    it { expect(subject.render).to eq 'My product: Skis (previous: Random)' }

  end

  describe 'passing options' do

    before { subject }

    let(:source) { '{% extends parent %}{% block product, short_name: true, priority: 10 %}Skis{% endblock %}' }

    it { expect(listener.events.size).to eq 3 }

    it { expect(listener.events.first.last[:priority]).to eq 10 }
    it { expect(listener.events.first.last[:short_name]).to eq true }
    it { expect(listener.events.last.last[:priority]).to eq 0 }
    it { expect(listener.events.last.last[:short_name]).to eq false }

  end

  describe 'live editing on' do

    before { subject }

    let(:context) { ::Liquid::Context.new({}, {}, { live_editing: true }) }

    it { expect(subject.render(context)).to eq 'My product: <span class="locomotive-block-anchor" data-element-id="product" style="visibility: hidden"></span>Skis' }

  end

end
