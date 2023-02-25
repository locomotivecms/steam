require 'spec_helper'

require_relative '../../../lib/locomotive/steam/middlewares/thread_safe'
require_relative '../../../lib/locomotive/steam/middlewares/concerns/helpers'
require_relative '../../../lib/locomotive/steam/middlewares/concerns/liquid_context'
require_relative '../../../lib/locomotive/steam/middlewares/section'

describe Locomotive::Steam::Middlewares::Section do

  let(:app)             { ->(env) { [200, env, 'app'] }}
  let(:url)             { 'http://example.com/foo/bar' }
  let(:env)             { env_for(url, 'steam.site' => site) }

  let(:site_drop)       { liquid_instance_double('SiteDrop', sections_content: { 'header' => { 'settings' => { 'name' => 'this should not be rendered in middleware' } } }) }
  let(:page_drop)       { liquid_instance_double('PageDrop', sections_content: { 'header' => { 'settings' => { 'name' => 'this should not be rendered in middleware' } } }) }
  let(:site)            { instance_double('Site', default_locale: 'en', locales: ['en'], to_liquid: site_drop) }
  let(:page)            { instance_double('Page', default_locale: 'en', locales: ['en'], to_liquid: page_drop) }
  let(:section)         { instance_double('Section', type: 'header', definition: {}, liquid_source: 'Here some {{ section.settings.name }}') }
  let(:section_finder)  { instance_double('SectionFinderService') }
  let(:repositories)    { instance_double('Repositories')}

  let(:services)        { instance_double(
                          'Services',
                          section_finder: section_finder,
                          snippet_finder: nil,
                          repositories: repositories,
                          locale: 'en')
                        }

  before do
    env['steam.page']             = page
    env['steam.services']         = services
    env['steam.locale']           = :en
    env['steam.liquid_registers'] = {}
    env['steam.liquid_assigns']   = {}
    env['steam.request']          = Rack::Request.new(env)
    env['steam.request'].add_header('HTTP_LOCOMOTIVE_SECTION_TYPE', 'header')
    allow(section_finder).to receive(:find).with('header').and_return(section)
  end

  subject do
    middleware = described_class.new(app)
    middleware.call(env)
  end

  it 'renders the HTML code related to the section' do
    is_expected.to eq [
      200,
      { "content-type" => "text/html" },
      [%(<div id="locomotive-section-header" class="locomotive-section" data-locomotive-section-type="header"><span id="header-section"></span>Here some </div>)]
    ]
  end

  context "the content of the section is in the request body" do

    before do
      allow(env['steam.request']).to receive(:body).and_return(StringIO.new(
        %({ "section_content": { "id": "dropzone-42", "settings": { "name": "modified HTML" } } })
      ))
    end

    it 'renders the HTML code related to the section' do
      is_expected.to eq [
        200,
        { "content-type" => "text/html" },
        [%(<div id="locomotive-section-dropzone-42" class="locomotive-section" data-locomotive-section-type="header"><span id="dropzone-42-section"></span>Here some modified HTML</div>)]
      ]
    end

  end

end
