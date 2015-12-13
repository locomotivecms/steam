require 'spec_helper'

require_relative '../../../lib/locomotive/steam/middlewares/thread_safe'
require_relative '../../../lib/locomotive/steam/middlewares/helpers'
require_relative '../../../lib/locomotive/steam/middlewares/private_access'

describe Locomotive::Steam::Middlewares::PrivateAccess do

  let(:password)        { nil }
  let(:site)            { instance_double('Site', name: 'Acme Corp', private_access: private_access, password: password) }
  let(:url)             { 'http://models.example.com' }
  let(:lock_screen)     { nil }
  let(:page_finder)     { instance_double('PageFinder', by_handle: lock_screen) }
  let(:services)        { instance_double('Services', page_finder: page_finder) }
  let(:session)         { {} }
  let(:app)             { ->(env) { [200, env, ['app']] } }
  let(:middleware)      { described_class.new(app) }
  let(:rack_env)        { build_env }
  let(:form)            { nil }

  subject { code, env, body = middleware.call(rack_env); body.first }

  describe 'no private access enabled' do

    let(:private_access) { false }

    it { is_expected.to eq 'app' }

  end

  describe 'private access enabled' do

    let(:private_access)  { true }

    context 'no password defined' do

      it { is_expected.not_to eq 'app' }

      describe 'with a custom lock screen page' do

        let(:lock_screen) { instance_double('LockScreenPage', title: 'LockScreen') }

        it { subject; expect(rack_env['steam.page'].title).to eq 'LockScreen' }

      end

    end

    context 'password defined' do

      let(:password)        { 'easyone' }
      let(:form)            { 'private_access_password=easyone' }

      describe 'right password submitted' do

        it { is_expected.to eq 'app' }
        it { subject; expect(session[:private_access_password]).to eq 'easyone'  }

      end

      describe 'right password already stored in the session' do

        let(:form)      { '' }
        let(:session)   { { private_access_password: 'easyone' } }

        it { is_expected.to eq 'app' }
        it { subject; expect(session[:private_access_password]).to eq 'easyone'  }

      end

      describe 'wrong password submitted' do

        let(:password)  { 'easyone' }
        let(:form)      { 'private_access_password=wrongone' }

        it { is_expected.to match /Wrong password/ }

      end

      describe 'feature disabled by a specific rack env variable' do

        let(:form) { '' }

        before { rack_env['steam.private_access_disabled'] = true }

        it { is_expected.to eq 'app' }

      end

    end

  end

  def build_env
    env_for(url, params: form).tap do |env|
      env['steam.site']       = site
      env['steam.request']    = Rack::Request.new(env)
      env['steam.services']   = services
      env['rack.session']     = session
    end
  end

end
