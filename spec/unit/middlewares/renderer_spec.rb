require 'spec_helper'

require_relative '../../../lib/locomotive/steam/middlewares/thread_safe'
require_relative '../../../lib/locomotive/steam/middlewares/concerns/helpers'
require_relative '../../../lib/locomotive/steam/middlewares/concerns/liquid_context'
require_relative '../../../lib/locomotive/steam/middlewares/renderer'

describe Locomotive::Steam::Middlewares::Renderer do

  let(:locale)      { 'en' }
  let(:site)        { instance_double('Site', default_locale: 'en') }
  let(:app)         { ->(env) { [200, env, 'app'] }}
  let(:middleware)  { described_class.new(app) }

  describe 'missing 404 page' do

    subject do
      middleware.call env_for('http://www.example.com', { 'steam.page' => nil, 'steam.locale' => locale, 'steam.site' => site })
    end

    specify 'return 404' do
      code, headers, response = subject
      expect(code).to eq(404)
      expect(response).to eq(["Your 404 page is missing. Please create it."])
    end

    context 'in another locale' do

      let(:locale) { 'fr' }

      specify 'return 200' do
        code, headers, response = subject
        expect(code).to eq(404)
        expect(response).to eq(["Your 404 page is missing in the fr locale. Please create it."])
      end

    end

  end

  describe 'rewriting of the asset urls' do

    let(:env) {
      env_for('http://www.example.com', {
        'steam.page'    => instance_double('Page', redirect?: false, not_found?: false, response_type: 'text/html'),
        'steam.locale'  => locale,
        'steam.site'    => site
      })
    }
    let(:site) { instance_double('Site', default_locale: 'en', asset_host: asset_host) }
    let(:content) { <<-HTML
<html>
  <meta content="https://cdn.locomotive.works/sites/42/theme/images/logo.png" property='og:image' />
  <script src="/sites/42/theme/javascripts/application.css"></script>
  <body>
    <img src="https://cdn.locomotive.works/steam/dynamic/42/abc/banner.png" />
    <a href='https://cdn.locomotive.works/sites/42/pages/1/assets/brochure.pdf'>My brochure</a>
    <p>https://cdn.locomotive.works/steam/dynamic/42/abc/banner.png</p>
  </body>
</html>
      HTML
    }

    before { allow_any_instance_of(described_class).to receive(:parse_and_render_liquid).and_return(content) }

    subject { _, _, response = middleware.call(env); response.first }

    context 'no asset host defined by the site' do

      let(:asset_host) { nil }

      it "doesn't rewrite the asset urls" do
        is_expected.to eq(content)
      end

    end

    context 'the site owns a custom asset host' do

      let(:asset_host) { 'https://cdn.mysite.dev' }

      it 'rewrites the asset urls' do
        is_expected.to eq(<<-HTML
<html>
  <meta content="https://cdn.mysite.dev/sites/42/theme/images/logo.png" property='og:image' />
  <script src="https://cdn.mysite.dev/sites/42/theme/javascripts/application.css"></script>
  <body>
    <img src="https://cdn.mysite.dev/steam/dynamic/42/abc/banner.png" />
    <a href='https://cdn.mysite.dev/sites/42/pages/1/assets/brochure.pdf'>My brochure</a>
    <p>https://cdn.locomotive.works/steam/dynamic/42/abc/banner.png</p>
  </body>
</html>
          HTML
        )
      end

    end

  end

end
