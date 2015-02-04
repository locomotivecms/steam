require 'spec_helper'

describe Locomotive::Steam::Liquid::Tags::Editable::Text do

  let(:page)        { instance_double('Page') }
  let(:listener)    { Liquid::SimpleEventsListener.new }
  let(:options)     { { events_listener: listener, page: page } }

  let(:source) { "{% editable_text title, hint: 'Simple short text' %}Hello world{% endeditable_text %}" }

  describe 'parsing' do

    subject { parse_template(source, options) }

    context 'valid syntax' do

      it 'does not raise an error' do
        expect { subject }.to_not raise_error
      end

    end

    context 'without a slug' do

      let(:source) { "{% editable_text %}{% endeditable_text %}" }

      it 'requires a slug' do
        expect { subject }.to raise_error(::Liquid::SyntaxError, "Liquid syntax error: Valid syntax: editable_text <slug>(, <options>)")
      end

    end

    context 'with a tag or block inside' do

      let(:source) { "{% editable_text title %}{{ test }}{% endeditable_text %}" }

      it 'does not allow it' do
        expect { subject }.to raise_error(::Liquid::SyntaxError, "Liquid syntax error: No liquid tags are allowed inside the editable_text \"title\" (block: default)")
      end

    end

    describe 'events' do

      before  { parse_template(source, options) }

      subject { listener.events.first.first }

      it 'records the name of the event' do
        is_expected.to eq :editable_text
      end

      describe 'attributes' do

        subject { listener.events.first.last[:attributes] }

        it { is_expected.to include(block: nil) }
        it { is_expected.to include(slug: 'title') }
        it { is_expected.to include(hint: 'Simple short text') }
        it { is_expected.to include(format: 'html') }
        it { is_expected.to include(rows: 10) }
        it { is_expected.to include(line_break: true) }
        it { is_expected.to include(content_from_default: 'Hello world') }

      end

    end

  end

  describe 'rendering' do

    let(:inline_editing) { false }

    let(:page)      { instance_double('Page', fullpath: 'hello-world') }
    let(:element)   { instance_double('EditableText', id: 42, default_content?: true, inline_editing?: true) }
    let(:services)  { Locomotive::Steam::Services.build_instance(nil) }
    let(:context)   { ::Liquid::Context.new({ 'inline_editing' => inline_editing }, {}, { page: page, services: services }) }

    before { allow(services.repositories.page).to receive(:editable_element_for).and_return(element) }

    subject { render_template(source, context, options) }

    it { is_expected.to eq 'Hello world' }

    context 'no element found' do

      let(:element) { nil }
      it { is_expected.to eq '' }

    end

    context 'modified content' do

      let(:element) { instance_double('EditableText', content: 'Hello world!', default_content?: false) }
      it { is_expected.to eq 'Hello world!' }

    end

    context 'inside blocks' do

      let(:source) { '{% block wrapper %}{% block sidebar %}{% editable_text title %}Hello world{% endeditable_text %}{% endblock %}{% endblock %}' }

      before { expect(services.repositories.page).to receive(:editable_element_for).with(page, 'wrapper/sidebar', 'title').and_return(element) }
      it { is_expected.to eq 'Hello world' }

    end

    context 'inline-editing mode' do

      let(:inline_editing) { true }
      it { is_expected.to eq '<span class="locomotive-editable-text" data-element-id="42">Hello world</span>' }

    end

    describe 'deprecated elements' do

      let(:listener)    { Liquid::SimpleEventsListener.new }
      let(:options)     { { events_listener: listener } }

      describe 'deprecated editable_long_text' do

        let(:source) { "{% editable_long_text body %}Hello world{% endeditable_long_text %}" }
        it { is_expected.to eq 'Hello world' }

      end

      describe 'deprecated editable_short_text' do

        let(:source) { "{% editable_short_text title %}Hello world{% endeditable_short_text %}" }
        it { is_expected.to eq 'Hello world' }

      end

    end

  end

end
