require 'spec_helper'

describe Locomotive::Steam::Liquid::Tags::Section do

  let(:request)       { instance_double('Request', env: {}) }
  let(:services)      { Locomotive::Steam::Services.build_instance(request) }
  let(:finder)        { services.section_finder }
  let(:source)        { 'Locomotive {% section header %}' }
  let(:live_editing)  { true }
  let(:content)       { {} }
  let(:alt_content)   { nil }
  let(:page)          { liquid_instance_double('Page', sections_content: content)}
  let(:assigns)       { { 'page' => page } }
  let(:context)       { ::Liquid::Context.new(assigns, {}, { services: services, live_editing: live_editing, _section_content: alt_content }) }

  describe 'parsing' do

    subject { parse_template(source) }

    describe 'raises an error if the syntax is incorrect' do
      let(:source) { 'Locomotive {% section %}' }
      it { expect { subject }.to raise_exception(Liquid::SyntaxError) }
    end

  end

  describe 'rendering' do

    before do
      allow(finder).to receive(:find).and_return(section)
    end

    subject { render_template(source, context) }

    let(:definition) { {
      type:  'header',
      class: 'my-awesome-header',
      settings: [
        { id: 'brand', type: 'text', label: 'Brand' },
        { id: 'image', type: 'image_picker' }
      ],
      blocks: [
        { type: 'menu_item', settings: [
          { id: 'title', type: 'text' },
          { id: 'image', type: 'image_picker' }
        ]}
      ],
      default: {
        settings: { brand: 'NoCoffee', image: 'foo.png' },
        blocks: [{ id: 42, type: 'menu_item', settings: { title: 'Home', image: 'foo.png' } }] }
    }.deep_stringify_keys }

    let(:section) { instance_double(
      'Header',
      slug:           'header',
      type:           'header',
      liquid_source:  liquid_source,
      definition:     definition,
    )}

    context 'no block' do

      let(:liquid_source) { %(built by <a>\n\t<strong>{{ section.settings.brand }}</strong></a>) }

      it { is_expected.to eq 'Locomotive'\
        ' <div id="locomotive-section-page-header"'\
        ' class="locomotive-section my-awesome-header"'\
        ' data-locomotive-section-type="header">'\
          '<span id="page-header-section"></span>'\
          'built by <a>' + %(\n\t) + '<strong data-locomotive-editor-setting="section-page-header.brand">NoCoffee</strong></a>'\
        '</div>' }

      context 'capturing the setting in a liquid variable' do

        let(:liquid_source) { %({% capture brand %}<strong class="bold">{{ section.settings.brand }}</strong>{% endcapture %}built by <a>\n\t{{ brand }}</a>) }

        it { is_expected.to eq 'Locomotive'\
          ' <div id="locomotive-section-page-header"'\
          ' class="locomotive-section my-awesome-header"'\
          ' data-locomotive-section-type="header">'\
            '<span id="page-header-section"></span>'\
            'built by <a>' + %(\n\t) + '<strong class="bold" data-locomotive-editor-setting="section-page-header.brand">NoCoffee</strong></a>'\
          '</div>' }

      end

      context 'with a non string type input' do

        let(:liquid_source) { 'built by <strong>{{ section.settings.image }}</strong>' }

        it { is_expected.to eq 'Locomotive'\
          ' <div id="locomotive-section-page-header"'\
          ' class="locomotive-section my-awesome-header"'\
          ' data-locomotive-section-type="header">'\
            '<span id="page-header-section"></span>'\
            'built by <strong>foo.png</strong>'\
          '</div>' }

      end

      context 'including the link_to liquid tag' do

        let(:liquid_source) { 'go to {% link_to home %}' }

        before { expect_any_instance_of(Locomotive::Steam::Liquid::Tags::LinkTo).to receive(:render).and_return('HOME') }

        it { is_expected.to eq 'Locomotive'\
          ' <div id="locomotive-section-page-header"'\
          ' class="locomotive-section my-awesome-header"'\
          ' data-locomotive-section-type="header">'\
            '<span id="page-header-section"></span>'\
            'go to HOME'\
          '</div>' }

      end

      context 'without the live editing feature enabled' do

        let(:live_editing) { false }

        it { is_expected.to eq 'Locomotive '\
          '<div id="locomotive-section-page-header"'\
          ' class="locomotive-section my-awesome-header"'\
          ' data-locomotive-section-type="header">'\
            '<span id="page-header-section"></span>'\
            'built by <a>' + %(\n\t) + '<strong>NoCoffee</strong></a>'\
          '</div>' }

      end

      context 'the developer wants to wrap herself/himself the section' do

        let(:liquid_source) { '<section class="section-header" id="{{ section.anchor_id }}" {{ section.locomotive_attributes }}>Hello world</section>' }

        it { is_expected.to eq 'Locomotive '\
          '<section class="section-header"'\
          ' id="page-header-section"'\
          ' data-locomotive-section-id="page-header"'\
          ' data-locomotive-section-type="header">'\
            'Hello world'\
          '</section>' }

      end

    end

    context 'with blocks' do

      let(:liquid_source) { '{% for foo in section.blocks %}<a href="/">{{ foo.settings.title }}</a>{% endfor %}' }

      it { is_expected.to eq 'Locomotive'\
        ' <div id="locomotive-section-page-header"'\
        ' class="locomotive-section my-awesome-header"'\
        ' data-locomotive-section-type="header">'\
          '<span id="page-header-section"></span>'\
          '<a href="/" data-locomotive-editor-setting="section-page-header-block.42.title">Home</a>'\
        '</div>' }

      context 'with a non text type input' do

        let(:liquid_source) { '{% for foo in section.blocks %}<a>{{ foo.settings.image }}</a>{% endfor %}' }

        it { is_expected.to eq 'Locomotive'\
          ' <div id="locomotive-section-page-header"'\
          ' class="locomotive-section my-awesome-header"'\
          ' data-locomotive-section-type="header">'\
            '<span id="page-header-section"></span>'\
            '<a>foo.png</a>'\
          '</div>' }

      end

    end

    context 'with page content' do
      let(:liquid_source) { 'built by <strong>{{ section.settings.brand }}</strong>' }

      context 'with on section' do

        context 'with simple type' do
          let(:content) {
            {
              header: {
                settings: { brand: 'Locomotive' },
                blocks:   []
              }
            }.deep_stringify_keys
          }

          it { is_expected.to eq 'Locomotive '\
            '<div id="locomotive-section-page-header"'\
            ' class="locomotive-section my-awesome-header"'\
            ' data-locomotive-section-type="header">'\
              '<span id="page-header-section"></span>'\
              'built by '\
              '<strong data-locomotive-editor-setting="section-page-header.brand">'\
                'Locomotive'\
              '</strong>'\
            '</div>' }
        end

        context 'with an id passed as an option' do

          let(:source) { 'Locomotive {% section header, id: "my_header" %}'}
          let(:content) {
            {
              'my_header': {
                settings: { brand: 'Locomotive' },
                blocks:   []
              }
            }.deep_stringify_keys
          }

          it { is_expected.to eq 'Locomotive '\
            '<div id="locomotive-section-page-my_header" '\
            'class="locomotive-section my-awesome-header" '\
            'data-locomotive-section-type="header">'\
              '<span id="page-my_header-section"></span>'\
              'built by '\
              '<strong data-locomotive-editor-setting="section-page-my_header.brand">'\
                'Locomotive'\
              '</strong>'\
            '</div>' }
        end

        context 'with an id within the content' do
          let(:source)      { 'Locomotive {% section header %}'}
          let(:alt_content) {
            {
              id: 'site-header',
              settings: { brand: 'Locomotive' },
              blocks:   []
            }.deep_stringify_keys
          }

          it { is_expected.to eq 'Locomotive '\
            '<div id="locomotive-section-site-header" '\
            'class="locomotive-section my-awesome-header" '\
            'data-locomotive-section-type="header">'\
              '<span id="site-header-section"></span>'\
              'built by '\
              '<strong data-locomotive-editor-setting="section-site-header.brand">'\
                'Locomotive'\
              '</strong>'\
            '</div>' }

        end

      end
    end


    context 'rendering error (action) found in the section' do

      let(:live_editing)  { false }
      let(:liquid_source) { '{% action "Hello world" %}a.b(+}{% endaction %}' }
      let(:section)       { instance_double('section',
        name:           'Hero',
        liquid_source:  liquid_source,
        definition:     { settings: [], blocks: [] }
      )}

      it 'raises ParsingRenderingError' do
        expect { subject }.to raise_exception(Locomotive::Steam::ParsingRenderingError)
      end
    end

  end

end

