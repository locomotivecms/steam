require 'spec_helper'

require_relative '../../../lib/locomotive/steam/middlewares/base'

describe Locomotive::Steam::Middlewares::Base do
  let(:app) { ->(env) { [200, env, 'app'] }}

  let :middleware do
    Locomotive::Steam::Middlewares::Base.new(app)
  end

  specify "return 200" do
    code, headers, response = middleware.call env_for('http://www.example.com', { 'steam.path' => 'my path' })
    expect(code).to eq(200)
  end

  def env_for url, opts={}
    Rack::MockRequest.env_for(url, opts)
  end
end
