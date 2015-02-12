require 'spec_helper'

describe Locomotive::Steam::Liquid::Tags::Editable::Control do

  let(:page)        { instance_double('Page') }
  let(:listener)    { Liquid::SimpleEventsListener.new }
  let(:options)     { { events_listener: listener, page: page } }

  let(:source) { "{% editable_control menu, hint: 'some text', options: 'true=Yes,false=No' %}false{% endeditable_control %}" }

  describe 'parsing' do

    subject { parse_template(source, options) }

    context 'valid syntax' do

      it 'does not raise an error' do
        expect { subject }.to_not raise_error
      end

    end

    context 'without a slug' do

      let(:source) { "{% editable_control %}{% endeditable_control %}" }

      it 'requires a slug' do
        expect { subject }.to raise_error(::Liquid::SyntaxError, "Liquid syntax error: Valid syntax: editable_control <slug>(, <options>)")
      end

    end

    context 'with a tag or block inside' do

      let(:source) { "{% editable_control menu, options: 'true=Yes,false=No' %}{{ test }}{% endeditable_control %}" }

      it 'does not allow it' do
        expect { subject }.to raise_error(::Liquid::SyntaxError, "Liquid syntax error: No liquid tags are allowed inside the editable_control \"menu\" (block: default)")
      end

    end

    describe 'events' do

      before  { parse_template(source, options) }

      subject { listener.events.first.first }

      it 'records the name of the event' do
        is_expected.to eq :editable_control
      end

      describe 'attributes' do

        subject { listener.events.first.last[:attributes] }

        it { is_expected.to include(block: nil) }
        it { is_expected.to include(slug: 'menu') }
        it { is_expected.to include(options: 'true=Yes,false=No') }
        it { is_expected.to include(hint: 'some text') }
        it { is_expected.to include(content: 'false') }

      end

    end

  end

  describe 'rendering' do

    let(:inline_editing) { false }

    let(:page)      { instance_double('Page', fullpath: 'hello-world') }
    let(:element)   { instance_double('EditableControl', id: 42, content: false) }
    let(:services)  { Locomotive::Steam::Services.build_instance(nil) }
    let(:context)   { ::Liquid::Context.new({ 'inline_editing' => inline_editing }, {}, { page: page, services: services }) }

    before { allow(services.repositories.page).to receive(:editable_element_for).and_return(element) }

    subject { render_template(source, context, options) }

    it { is_expected.to eq 'false' }

    context 'no element found, render the default content' do

      let(:element) { nil }
      it { is_expected.to eq 'false' }

    end

    context 'modified value' do

      let(:element) { instance_double('EditableControl', content: 'true') }
      it { is_expected.to eq 'true' }

    end

    context 'inside blocks' do

      let(:source) { '{% block wrapper %}{% block sidebar %}{% editable_control menu %}true{% endeditable_control %}{% endblock %}{% endblock %}' }

      before { expect(services.repositories.page).to receive(:editable_element_for).with(page, 'wrapper/sidebar', 'menu').and_return(element) }
      it { is_expected.to eq 'false' }

    end

  end

end
