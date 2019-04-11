require 'spec_helper'

require_relative '../../../lib/locomotive/steam/middlewares/thread_safe'
require_relative '../../../lib/locomotive/steam/middlewares/concerns/helpers'
require_relative '../../../lib/locomotive/steam/middlewares/locale'

describe Locomotive::Steam::Middlewares::Locale do

  let(:site)            { instance_double('Site', default_locale: :de, locales: [:de, :fr, :en]) }
  let(:url)             { 'http://models.example.com' }
  let(:app)             { ->(env) { [200, env, 'app'] } }
  let(:cookie_lang)     { nil }
  let(:cookie_service)  { instance_double('Cookie Service', :get => cookie_lang) }
  let(:services)        { instance_double('Services', :locale= => 'en', :cookie => cookie_service) }
  let(:middleware)      { Locomotive::Steam::Middlewares::Locale.new(app) }
  let(:accept_language) { '' }

  subject do
    env = env_for(
        url,
        'steam.site' => site,
        'HTTP_ACCEPT_LANGUAGE' => accept_language)
    env['steam.request']  = Rack::Request.new(env)
    env['steam.services'] = services
    env['steam.locale']
    code, env = middleware.call(env)
    [env['steam.locale'], env['steam.path']]
  end

  describe 'whatever url' do

    let(:url) { 'http://models.example.com/whatever' }

    it 'should set the cookies' do
       expect(cookie_service).to receive(:set).with('steam-locale', {
           value: :de,
           path: '/',
           max_age: 1.year
       }).and_return(nil)
       is_expected.to eq [:de,  '/whatever']
    end

  end

  describe 'browse site with' do

    before { allow(cookie_service).to receive(:set).and_return(nil) }

    describe 'locale defined in the path' do

      let(:url) { 'http://models.example.com/de/hello-de/foo' }

      it { is_expected.to eq [:de, '/hello-de/foo'] }

    end

    describe 'no locale defined in the path' do

      describe 'first connexion' do

        context 'without accept-language header' do

          it { is_expected.to eq [:de, '/'] }

        end

        context 'with accept-language header' do

          let(:accept_language) { 'fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7' }

          it { is_expected.to eq [:fr,  '/'] }

          context 'with url path' do

            let(:url) { 'http://models.example.com/werkzeug' }

            it { is_expected.to eq [:de, '/werkzeug'] }

          end

        end

      end

      context 'user with cookie, use it' do

        let(:cookie_lang) { 'en' }

        it { is_expected.to eq [:en, '/'] }

      end

    end

    describe 'locale asked in the request params' do

      context 'the locale is blank' do

        let(:url) { 'http://models.example.com?locale=' }

        it { is_expected.to eq [:de, '/'] }

      end

      context 'the locale exists' do

        let(:url) { 'http://models.example.com?locale=en' }

        it { is_expected.to eq [:en, '/'] }

      end

      context 'the locale is unknown' do

        let(:url) { 'http://models.example.com?locale=onload' }

        it { is_expected.to eq [:de, '/'] }

      end

    end
  end
end
