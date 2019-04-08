require 'spec_helper'

require_relative '../../../lib/locomotive/steam/middlewares/thread_safe'
require_relative '../../../lib/locomotive/steam/middlewares/helpers'
require_relative '../../../lib/locomotive/steam/middlewares/locale'

describe Locomotive::Steam::Middlewares::Locale do

  let(:site)            { instance_double('Site', default_locale: :de, locales: [:de, :fr, :en]) }
  let(:url)             { 'http://models.example.com' }
  let(:app)             { ->(env) { [200, env, 'app'] } }
  let(:cookie_lang)     { nil }
  let(:cookie_service)  { instance_double('Cookie Service', :get => cookie_lang) }
  let(:services)        { instance_double('Services', :locale= => 'en', :cookie => cookie_service) }
  let(:middleware)      { Locomotive::Steam::Middlewares::Locale.new(app) }
  let(:cookie)          { {} }
  let(:accept_language) { '' }
  let(:expected_lang)   { :de }
  let(:cookie)          { { value: expected_lang, path: '/', max_age: 1.year } }

  subject do
    env = env_for(
        url,
        'steam.site' => site,
        'HTTP_ACCEPT_LANGUAGE' => accept_language)
    env['steam.request']  = Rack::Request.new(env)
    env['steam.services'] = services
    code, env = middleware.call(env)
    env['steam.locale']
  end

  describe 'no locale defined in the path' do

    describe 'first connexion' do

      context 'without accept-language header' do

        it 'should use default language' do
          expect(cookie_service).to receive(:set).with('steam-locale', cookie).and_return(nil)
          is_expected.to eq expected_lang
        end

      end

      context 'with accept-language header' do

        let(:accept_language) { 'fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7' }
        let(:expected_lang) { :fr }

        it 'should use "fr" in header' do
          expect(cookie_service).to receive(:set).with('steam-locale', cookie).and_return(nil)
          is_expected.to eq expected_lang
        end

        context 'with url path' do

          let(:url) { 'http://models.example.com/werkzeug' }
          let(:expected_lang) { :de }

          it 'should use "de" in path' do
            expect(cookie_service).to receive(:set).with('steam-locale', cookie).and_return(nil)
            is_expected.to eq expected_lang
          end

        end

      end

    end

    context 'user with cookie, use it' do

      let(:cookie_lang) { 'en' }
      let(:expected_lang) { :en }

      it 'should use "en" in cookie' do
        expect(cookie_service).to receive(:set).with('steam-locale', cookie).and_return(nil)
        is_expected.to eq expected_lang
      end

    end

  end

  describe 'locale asked in the request params' do

    context 'the locale is blank' do

      let(:url) { 'http://models.example.com?locale=' }

      it 'should use default locale "de"' do
        expect(cookie_service).to receive(:set).with('steam-locale', cookie).and_return(nil)
        is_expected.to eq expected_lang
      end

    end

    context 'the locale exists' do

      let(:url) { 'http://models.example.com?locale=en' }
      let(:expected_lang) { :en }

      it 'should use existing locale "en"' do
        expect(cookie_service).to receive(:set).with('steam-locale', cookie).and_return(nil)
        is_expected.to eq expected_lang
      end

    end

    context 'the locale is unknown' do

      let(:url) { 'http://models.example.com?locale=onload' }

      it 'should use default locale "de"' do
        expect(cookie_service).to receive(:set).with('steam-locale', cookie).and_return(nil)
        is_expected.to eq expected_lang
      end

    end

  end
end
