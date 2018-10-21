require 'spec_helper'

require_relative '../../../lib/locomotive/steam/middlewares/thread_safe'
require_relative '../../../lib/locomotive/steam/middlewares/helpers'
require_relative '../../../lib/locomotive/steam/middlewares/locale'

describe Locomotive::Steam::Middlewares::Locale do

  let(:site)            { instance_double('Site', default_locale: :de, locales: [:de, :fr, :en]) }
  let(:url)             { 'http://models.example.com' }
  let(:app)             { ->(env) { [200, env, 'app'] } }
  let(:services)        { instance_double('Services', :locale= => 'en') }
  let(:middleware)      { Locomotive::Steam::Middlewares::Locale.new(app) }
  let(:session)         { {} }
  let(:accept_language) { '' }

  subject do
    env = env_for(
        url,
        'steam.site' => site,
        'rack.session' => session,
        'HTTP_ACCEPT_LANGUAGE' => accept_language)
    env['steam.request']  = Rack::Request.new(env)
    env['steam.services'] = services
    code, env = middleware.call(env)
    [env['steam.locale'], session['steam-locale']&.to_sym]
  end

  describe 'no locale defined in the path' do

    describe 'first connexion' do

      context 'without accept-language header' do

        it { is_expected.to eq [:de, :de] }

      end

      context 'with accept-language header' do

        let(:accept_language) { 'fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7' }

        it { is_expected.to eq [:fr, :fr] }

        context 'with url path' do

          let(:url) { 'http://models.example.com/werkzeug' }

          it { is_expected.to eq [:de, :de] }

        end

      end

    end

    context 'user with session, use it' do

      let(:session) { {'steam-locale' => 'en'} }

      it { is_expected.to eq [:en, :en] }

    end

  end

  describe 'locale asked in the request params' do

    context 'the locale is blank' do

      let(:url) { 'http://models.example.com?locale=' }

      it { is_expected.to eq [:de, :de] }

    end

    context 'the locale exists' do

      let(:url) { 'http://models.example.com?locale=en' }

      it { is_expected.to eq [:en, :en] }

    end

    context 'the locale is unknown' do

      let(:url) { 'http://models.example.com?locale=onload' }

      it { is_expected.to eq [:de, :de] }

    end

  end
end
