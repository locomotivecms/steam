require 'spec_helper'

describe Locomotive::Steam::Liquid::Tags::Editable::Text do

  let(:page)        { instance_double('Page') }
  let!(:listener)   { Liquid::SimpleEventsListener.new }
  let(:options)     { { page: page } }

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
        is_expected.to eq 'steam.parse.editable.editable_text'
      end

      describe 'attributes' do

        subject { listener.events.first.last[:attributes] }

        it { is_expected.to include(block: nil) }
        it { is_expected.to include(type: :editable_text) }
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

    let(:live_editing)    { false }
    let(:element_editing) { true }

    let(:page)        { instance_double('Page', fullpath: 'hello-world') }
    let(:element)     { instance_double('EditableText', _id: 42, id: 42, default_content?: true, inline_editing?: element_editing, inline_editing: element_editing, format: 'html') }
    let(:services)    { Locomotive::Steam::Services.build_instance(nil) }
    let(:context)     { ::Liquid::Context.new({}, {}, { page: page, services: services, live_editing: live_editing }) }

    before { allow(services.editable_element).to receive(:find).and_return(element) }

    subject { render_template(source, context, options) }

    it { is_expected.to eq 'Hello world' }

    context 'no element found, render the default content' do

      let(:element) { nil }
      it { is_expected.to eq 'Hello world' }

    end

    context 'modified content' do

      let(:element) { instance_double('EditableText', content: 'Hello world!', default_content?: false, format: 'html') }
      it { is_expected.to eq 'Hello world!' }

    end

    context 'inside blocks' do

      let(:source) { '{% block wrapper %}{% block sidebar %}{% editable_text title %}Hello world{% endeditable_text %}{% endblock %}{% endblock %}' }

      before { expect(services.editable_element).to receive(:find).with(page, 'wrapper/sidebar', 'title').and_return(element) }
      it { is_expected.to eq 'Hello world' }

    end

    context 'markdown format' do

      let(:element) { instance_double('EditableText', content: "#Hello world!\nLorem ipsum", default_content?: false, format: 'markdown') }
      it { is_expected.to eq "<h1>Hello world!</h1>\n<p>Lorem ipsum</p>\n" }

    end

    context 'inline-editing mode' do

      let(:live_editing) { true }
      it { is_expected.to eq '<span class="locomotive-editable-text" id="locomotive-editable-text-title" data-element-id="42">Hello world</span>' }

      context 'with inside blocks' do

        let(:source) { '{% block wrapper %}{% block sidebar %}{% editable_text title %}Hello world{% endeditable_text %}{% endblock %}{% endblock %}' }
        it { is_expected.to eq '<span class="locomotive-editable-text" id="locomotive-editable-text-wrapper-sidebar-title" data-element-id="42">Hello world</span>' }

      end

      context 'editing disabled for the element' do

        let(:element_editing) { false }
        it { is_expected.to eq 'Hello world' }

      end

    end

    describe 'deprecated elements' do

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
