require 'spec_helper'

require_relative '../../../lib/locomotive/steam/middlewares/thread_safe'
require_relative '../../../lib/locomotive/steam/middlewares/helpers'
require_relative '../../../lib/locomotive/steam/middlewares/locale'

describe Locomotive::Steam::Middlewares::Locale do

  let(:site)            { instance_double('Site', default_locale: :de, locales: %w(de fr)) }
  let(:url)             { 'http://models.example.com' }
  let(:app)             { ->(env) { [200, env, 'app'] } }
  let(:services)        { instance_double('Services', :locale= => 'en') }
  let(:middleware)      { Locomotive::Steam::Middlewares::Locale.new(app) }

  subject do
    env = env_for(url, 'steam.site' => site)
    env['steam.request']  = Rack::Request.new(env)
    env['steam.services'] = services
    code, env = middleware.call(env)
    env['steam.locale']
  end

  describe 'locale asked in the request params' do

    context 'the locale is blank' do

      let(:url) { 'http://models.example.com?locale=' }

      it { is_expected.to eq :de }

    end

    context 'the locale exists' do

      let(:url) { 'http://models.example.com?locale=fr' }

      it { is_expected.to eq 'fr' }

    end

    context 'the locale is unknown' do

      let(:url) { 'http://models.example.com?locale=onload' }

      it { is_expected.to eq :de }

    end


  end

end
