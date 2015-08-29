require 'spec_helper'

describe Locomotive::Steam::Liquid::Tags::Editable::Model do

  let(:page)        { instance_double('Page') }
  let!(:listener)   { Liquid::SimpleEventsListener.new }
  let(:options)     { { page: page } }

  let(:source) { "{% editable_model posts, hint: 'some text' %}Lorem ipsum{% endeditable_model %}" }

  describe 'parsing' do

    subject { parse_template(source, options) }

    context 'valid syntax' do

      it 'does not raise an error' do
        expect { subject }.to_not raise_error
      end

    end

    context 'without a slug' do

      let(:source) { "{% editable_model %}{% endeditable_model %}" }

      it 'requires a slug' do
        expect { subject }.to raise_error(::Liquid::SyntaxError, "Liquid syntax error: Valid syntax: editable_model <slug>(, <options>)")
      end

    end

    describe 'events' do

      before  { parse_template(source, options) }

      subject { listener.events.first.first }

      it 'records the name of the event' do
        is_expected.to eq "steam.parse.editable.editable_model"
      end

      describe 'attributes' do

        subject { listener.events.first.last[:attributes] }

        it { is_expected.to include(block: nil) }
        it { is_expected.to include(type: :editable_model) }
        it { is_expected.to include(slug: 'posts') }
        it { is_expected.to include(hint: 'some text') }

      end

    end

  end

  describe 'rendering' do

    let(:inline_editing) { false }

    let(:page)        { instance_double('Page', fullpath: 'hello-world') }
    let(:element)     { instance_double('EditableModel', id: 42) }
    let(:services)    { Locomotive::Steam::Services.build_instance(nil) }
    let(:context)     { ::Liquid::Context.new({ 'inline_editing' => inline_editing }, {}, { page: page, services: services }) }

    before { allow(services.editable_element).to receive(:find).and_return(element) }

    subject { render_template(source, context, options) }

    it { is_expected.to eq 'Lorem ipsum' }

    context 'inside blocks' do

      let(:source) { '{% block wrapper %}{% block sidebar %}{% editable_model posts %}Lorem ipsum{% endeditable_model %}{% endblock %}{% endblock %}' }

      before { expect(services.editable_element).not_to receive(:find).with(page, 'wrapper/sidebar', 'posts') }
      it { is_expected.to eq 'Lorem ipsum' }

    end

  end

end
