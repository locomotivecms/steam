require 'spec_helper'

require_relative '../../../lib/locomotive/steam/middlewares/thread_safe'
require_relative '../../../lib/locomotive/steam/middlewares/concerns/helpers'
require_relative '../../../lib/locomotive/steam/middlewares/page'

describe Locomotive::Steam::Middlewares::Page do

  let(:live_editing)    { nil }
  let(:published)       { true }
  let(:page_not_found)  { instance_double('PageNotFound', not_found?: true) }
  let(:page)            { instance_double('Page', title: 'Hello world', fullpath: 'hello-world', not_found?: false, published?: published) }
  let(:pages)           { [page] }
  let(:site)            { instance_double('Site', default_locale: 'en') }
  let(:service)         { instance_double('PageFinder', match: pages) }
  let(:url)             { 'http://models.example.com' }
  let(:app)             { ->(env) { [200, env, 'app'] } }
  let(:middleware)      { described_class.new(app) }

  subject do
    env = env_for(url, 'steam.site' => site)
    env['steam.path']         = 'hello-world'
    env['steam.locale']       = 'en'
    env['steam.request']      = Rack::Request.new(env)
    env['steam.live_editing'] = live_editing
    code, env = middleware.call(env)
    env['steam.page']
  end

  before do
    allow_any_instance_of(described_class).to receive(:page_finder).and_return(service)
    allow(service).to receive(:find).with('404').and_return(page_not_found)
  end

  it { is_expected.to eq page }

  context "page doesn't exist" do

    let(:pages) { [] }

    it { is_expected.to eq page_not_found }

  end

  context 'page is unpublished' do

    let(:published) { false }

    it { is_expected.to eq page_not_found }

    context 'the live editing mode is on' do

      let(:live_editing) { true }

      it 'has to display it' do
        is_expected.to eq page
      end

    end

  end

end
