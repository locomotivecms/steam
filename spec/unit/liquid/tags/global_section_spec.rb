require 'spec_helper'

describe Locomotive::Steam::Liquid::Tags::GlobalSection do

  let(:services)      { Locomotive::Steam::Services.build_instance(nil) }
  let(:finder)        { services.section_finder }
  let(:source)        { 'Locomotive {% global_section header %}' }
  let(:live_editing)  { true }
  let(:content)       { {} }
  let(:site)          { liquid_instance_double('Site', sections_content: content) }
  let(:assigns)       { { 'site' => site } }
  let(:context)       { ::Liquid::Context.new(assigns, {}, { services: services, live_editing: live_editing }) }

  before do
    allow(finder).to receive(:find).and_return(section)
  end

  describe 'rendering' do

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

    subject { render_template(source, context) }

    context 'no block' do

      let(:liquid_source) { %(built by <a>\n\t<strong>{{ section.settings.brand }}</strong></a>) }

      it { is_expected.to eq %(Locomotive <div id="locomotive-section-site-header" class="locomotive-section my-awesome-header" data-locomotive-section-type="header">built by <a>\n\t<strong data-locomotive-editor-setting="section-site-header.brand">NoCoffee</strong></a></div>) }

      context 'capturing the setting in a liquid variable' do

        let(:liquid_source) { %({% capture brand %}<strong class="bold">{{ section.settings.brand }}</strong>{% endcapture %}built by <a>\n\t{{ brand }}</a>) }

        it { is_expected.to eq %(Locomotive <div id="locomotive-section-site-header" class="locomotive-section my-awesome-header" data-locomotive-section-type="header">built by <a>\n\t<strong class="bold" data-locomotive-editor-setting="section-site-header.brand">NoCoffee</strong></a></div>) }

      end


      context 'with a non string type input' do

        let(:liquid_source) { 'built by <strong>{{ section.settings.image }}</strong>' }

        it { is_expected.to eq 'Locomotive <div id="locomotive-section-site-header" class="locomotive-section my-awesome-header" data-locomotive-section-type="header">built by <strong>foo.png</strong></div>' }

      end

      context 'without the live editing feature enabled' do

        let(:live_editing) { false }

        it { is_expected.to eq %(Locomotive <div id="locomotive-section-site-header" class="locomotive-section my-awesome-header" data-locomotive-section-type="header">built by <a>\n\t<strong>NoCoffee</strong></a></div>) }

      end

    end

    context 'with blocks' do

      let(:liquid_source) { '{% for foo in section.blocks %}<a href="/">{{ foo.settings.title }}</a>{% endfor %}' }

      it { is_expected.to eq 'Locomotive <div id="locomotive-section-site-header" class="locomotive-section my-awesome-header" data-locomotive-section-type="header"><a href="/" data-locomotive-editor-setting="section-site-header-block.42.title">Home</a></div>' }

      context 'with a non text type input' do

        let(:liquid_source) { '{% for foo in section.blocks %}<a>{{ foo.settings.image }}</a>{% endfor %}' }

        it { is_expected.to eq 'Locomotive <div id="locomotive-section-site-header" class="locomotive-section my-awesome-header" data-locomotive-section-type="header"><a>foo.png</a></div>' }

      end

    end

    context 'with site value' do
      let(:content) {
        {
          header: {
            settings: { brand: 'Locomotive' },
            blocks:   []
          }
        }.deep_stringify_keys
      }

      let(:liquid_source) { 'built by <strong>{{ section.settings.brand }}</strong>' }

      it { is_expected.to eq 'Locomotive <div id="locomotive-section-site-header" class="locomotive-section my-awesome-header" data-locomotive-section-type="header">built by <strong data-locomotive-editor-setting="section-site-header.brand">Locomotive</strong></div>' }

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
