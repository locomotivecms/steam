require 'spec_helper'

describe Locomotive::Steam::Liquid::Tags::SectionsDropzone do

  let(:services)      { Locomotive::Steam::Services.build_instance(nil) }
  let(:finder)        { services.section_finder }
  let(:source)        { '{% sections_dropzone %}' }
  let(:live_editing)  { true }
  let(:page)          { liquid_instance_double('Page', sections_content: content) }
  let(:assigns)       { { 'page' => page } }
  let(:registers)     { { services: services, live_editing: live_editing } }
  let(:context)       { ::Liquid::Context.new(assigns, {}, registers) }

  describe 'rendering' do

    subject { render_template(source, context) }

    context 'no sections' do

      let(:content) { [] }

      it 'renders an empty string' do
        is_expected.to eq '<div class="locomotive-sections"></div>'
      end

    end

    context 'with sections' do

      let(:content) { [
        {
          type:     'hero',
          settings: { title: 'Hello world' },
          blocks:   []
        }.deep_stringify_keys,
        {
          type:     'slideshow',
          settings: {},
          blocks:   [{ settings: { title: 'Slide 1' } }, { settings: { title: 'Slide 2' } }]
        }.deep_stringify_keys
      ] }

      let(:hero_source) { %(<h1>{{ section.settings.title }}</h1>) }
      let(:slideshow_source) { %({% for block in section.blocks %}<p>{{ block.settings.title }}</p>{% endfor %}) }

      let(:hero_section) {
        instance_double('Hero',
          slug: 'hero',
          type: 'hero',
          definition: { settings: [{ id: 'title', type: 'text' }], blocks: [] }.deep_stringify_keys,
          liquid_source: hero_source)
      }
      let(:slideshow_section) {
        instance_double('Slideshow',
          slug: 'slideshow',
          type: 'slideshow',
          definition: {
            settings: [],
            blocks: [{ settings: [{ id: 'title', type: 'text' }] }]
          }.deep_stringify_keys,
          liquid_source: slideshow_source) }

      before do
        allow(finder).to receive(:find).with('hero').and_return(hero_section)
        allow(finder).to receive(:find).with('slideshow').and_return(slideshow_section)
      end

      it 'renders the list of sections' do
        is_expected.to eq <<-HTML
          <div class="locomotive-sections">
            <div id="locomotive-section-0" class="locomotive-section" data-locomotive-section-type="hero">
              <h1 data-locomotive-editor-setting="section-0.title">Hello world</h1>
            </div>
            <div id="locomotive-section-1" class="locomotive-section" data-locomotive-section-type="slideshow">
              <p data-locomotive-editor-setting="section-1-block.0.title">Slide 1</p>
              <p data-locomotive-editor-setting="section-1-block.1.title">Slide 2</p>
            </div>
          </div>
        HTML
        .strip.gsub(/\n\s+/, '')
      end

      context 'live editing is off' do

        let(:live_editing) { false }

        it 'renders the list of sections' do
          is_expected.to eq <<-HTML
            <div class="locomotive-sections">
              <div id="locomotive-section-0" class="locomotive-section" data-locomotive-section-type="hero">
                <h1>Hello world</h1>
              </div>
              <div id="locomotive-section-1" class="locomotive-section" data-locomotive-section-type="slideshow">
                <p>Slide 1</p>
                <p>Slide 2</p>
              </div>
            </div>
          HTML
          .strip.gsub(/\n\s+/, '')
        end

      end

    end

  end
end
