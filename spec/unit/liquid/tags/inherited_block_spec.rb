require 'spec_helper'

describe Locomotive::Steam::Liquid::Tags::InheritedBlock do

  let(:parent_source) { 'My product: {% block product %}Random{% endblock %}' }
  let(:parent)        { instance_double('Index', liquid_source: parent_source, template: nil, :template= => nil) }
  let(:source)        { '{% extends parent %}{% block product %}Skis{% endblock %}' }
  let(:page)          { instance_double('Page') }

  let!(:listener)     { Liquid::SimpleEventsListener.new }
  let(:finder)        { instance_double('Finder', find: parent) }
  let(:options)       { { page: page, parent_finder: finder, parser: Locomotive::Steam::LiquidParserService.new(nil, nil) } }

  let!(:template)     { parse_template(source, options) }

  describe 'without a super block' do

    it { expect(listener.events.size).to eq 3 }
    it { expect(listener.events.first.last[:found_super]).to eq false }
    it { expect(template.render).to eq 'My product: Skis' }

  end

  describe 'with a super block' do

    let(:source) { '{% extends parent %}{% block product %}Skis (previous: {{ block.super }}){% endblock %}' }

    it { expect(listener.events.first.last[:found_super]).to eq true }
    it { expect(template.render).to eq 'My product: Skis (previous: Random)' }

  end

  describe 'passing options' do

    let(:source) { '{% extends parent %}{% block product, short_name: true, priority: 10 %}Skis{% endblock %}' }

    it { expect(listener.events.size).to eq 3 }

    it { expect(listener.events.first.last[:priority]).to eq 10 }
    it { expect(listener.events.first.last[:short_name]).to eq true }
    it { expect(listener.events.last.last[:priority]).to eq 0 }
    it { expect(listener.events.last.last[:short_name]).to eq false }

  end

  describe 'live editing on' do

    let(:context) { ::Liquid::Context.new({}, {}, { live_editing: true }) }

    it { expect(template.render(context)).to eq 'My product: <span class="locomotive-block-anchor" data-element-id="product" style="visibility: hidden"></span>Skis' }

  end

end
