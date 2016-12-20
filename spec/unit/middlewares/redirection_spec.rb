require 'spec_helper'

require_relative '../../../lib/locomotive/steam/middlewares/thread_safe'
require_relative '../../../lib/locomotive/steam/middlewares/helpers'
require_relative '../../../lib/locomotive/steam/middlewares/redirection'

describe Locomotive::Steam::Middlewares::Redirection do

  let(:site)            { instance_double('Site') }
  let(:url)             { 'http://models.example.com/about-us' }
  let(:locomotive_path) { nil }
  let(:app)             { ->(env) { [200, env, 'app'] } }
  let(:middleware)      { described_class.new(app) }

  subject do
    env = env_for(url, 'steam.site' => site)
    env['steam.request']    = Rack::Request.new(env)
    env['locomotive.path']  = locomotive_path
    code, env = middleware.call(env)
    [code, env['Location']]
  end

  describe 'no redirection exception raised' do

    it { is_expected.to eq [200, nil] }

  end

  describe 'redirection exception raised' do

    let(:app) { ->(env) { raise Locomotive::Steam::RedirectionException.new('/sign_in') } }

    it { is_expected.to eq [302, '/sign_in'] }

  end

end
