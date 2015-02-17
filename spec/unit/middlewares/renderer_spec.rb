require 'spec_helper'

require_relative '../../../lib/locomotive/steam/middlewares/threadsafe'
require_relative '../../../lib/locomotive/steam/middlewares/helpers'
require_relative '../../../lib/locomotive/steam/middlewares/renderer'

describe Locomotive::Steam::Middlewares::Renderer do

  let(:app) { ->(env) { [200, env, 'app'] }}

  let :middleware do
    Locomotive::Steam::Middlewares::Renderer.new(app)
  end

  describe 'missing 404 page' do

    subject do
      middleware.call env_for('http://www.example.com', { 'steam.page' => nil })
    end

    specify 'return 200' do
      code, headers, response = subject
      expect(code).to eq(404)
      expect(response).to eq(['Missing 404 page'])
    end

  end

  def env_for(url, opts={})
    Rack::MockRequest.env_for(url, opts)
  end
end
