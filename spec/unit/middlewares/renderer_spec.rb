require 'spec_helper'

require_relative '../../../lib/locomotive/steam/middlewares/thread_safe'
require_relative '../../../lib/locomotive/steam/middlewares/helpers'
require_relative '../../../lib/locomotive/steam/middlewares/renderer'

describe Locomotive::Steam::Middlewares::Renderer do

  let(:app) { ->(env) { [200, env, 'app'] }}

  let(:middleware) { described_class.new(app) }

  describe 'missing 404 page' do

    let(:locale)  { 'en' }
    let(:site)    { instance_double('Site', default_locale: 'en') }

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

end
