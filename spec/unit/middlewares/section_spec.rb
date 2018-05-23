require 'spec_helper'

require_relative '../../../lib/locomotive/steam/middlewares/thread_safe'
require_relative '../../../lib/locomotive/steam/middlewares/concerns/helpers'
require_relative '../../../lib/locomotive/steam/middlewares/concerns/liquid_context'
require_relative '../../../lib/locomotive/steam/middlewares/section'

describe Locomotive::Steam::Middlewares::Section do

  let(:app)            { ->(env) { [200, env, 'app'] }}
  let(:url)            { 'http://example.com/_sections/header' }
  let(:env)            { env_for(url, 'steam.site' => site) }

  let(:site)           { instance_double('Site', default_locale: 'en', locales: ['en'], to_liquid: '') }
  let(:section)        { instance_double('Section', type: 'fancy_section', definition: {}, liquid_source: 'Here some HTML') }
  let(:section_finder) { instance_double('SectionFinderService') }
  let(:repositories)   { instance_double('Repositories')}

  let(:services)       { instance_double(
                          'Services',
                          section_finder: section_finder,
                          repositories: repositories,
                          locale: 'en')
                        }

  before do
    env['steam.page'] = nil
    env['steam.services'] = services
    env['steam.locale'] = :en
    env['steam.request'] = Rack::Request.new(env)
    allow(section_finder).to receive(:find).with('header').and_return(section)
  end

  subject do
    middleware = described_class.new(app)
    middleware.call(env)
  end

  it 'works' do
    is_expected.to eq [200, {"Content-Type"=>"text/html"}, [%(<div id="locomotive-section-fancy_section" class="locomotive-section ">Here some HTML</div>)]]
  end

end
