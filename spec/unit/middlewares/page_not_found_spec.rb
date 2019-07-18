require 'spec_helper'

require_relative '../../../lib/locomotive/steam/middlewares/thread_safe'
require_relative '../../../lib/locomotive/steam/middlewares/concerns/helpers'
require_relative '../../../lib/locomotive/steam/middlewares/concerns/liquid_context'
require_relative '../../../lib/locomotive/steam/middlewares/concerns/rendering'
require_relative '../../../lib/locomotive/steam/middlewares/page_not_found'

describe Locomotive::Steam::Middlewares::PageNotFound do

  let(:site)            { instance_double('Site', asset_host: nil) }
  let(:url)             { 'http://models.example.com/about-us' }
  let(:page_finder)     { instance_double('PageFinder') }
  let(:locomotive_path) { nil }
  let(:app)             { ->(env) { [200, env, ['Hello world']] } }
  let(:middleware)      { described_class.new(app) }

  subject do
    env = env_for(url, 'steam.site' => site)
    env['steam.request']    = Rack::Request.new(env)
    env['steam.services']   = instance_double('Services', page_finder: page_finder)
    env['locomotive.path']  = locomotive_path
    code, _, body = middleware.call(env)
    [code, body]
  end

  describe 'no page not found exception raised' do

    it { is_expected.to eq [200, ['Hello world']] }

  end

  describe 'page not found exception raised' do

    let(:page)  { instance_double('PageNotFound',not_found?: true, response_type: 'text/html') }
    let(:app)   { ->(env) { raise Locomotive::Steam::PageNotFoundException.new } }

    it 'renders the 404 error page' do
      expect(page_finder).to receive(:find).with('404').and_return(page)
      expect_any_instance_of(described_class).to receive(:parse_and_render_liquid).and_return("We're sorry")
      is_expected.to eq [404, ["We're sorry"]]
    end

  end

end
