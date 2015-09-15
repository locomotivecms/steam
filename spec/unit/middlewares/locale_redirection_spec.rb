require 'spec_helper'

require_relative '../../../lib/locomotive/steam/middlewares/thread_safe'
require_relative '../../../lib/locomotive/steam/middlewares/helpers'
require_relative '../../../lib/locomotive/steam/middlewares/locale_redirection'

describe Locomotive::Steam::Middlewares::LocaleRedirection do

  let(:prefixed)        { false }
  let(:site)            { instance_double('Site', prefix_default_locale: prefixed, default_locale: :de, locales: %w(de fr)) }
  let(:url)             { 'http://models.example.com' }
  let(:app)             { ->(env) { [200, env, 'app'] } }
  let(:middleware)      { Locomotive::Steam::Middlewares::LocaleRedirection.new(app) }
  let(:locale)          { 'de' }
  let(:locale_in_path)  { true }

  subject do
    env = env_for(url, 'steam.site' => site, 'steam.locale' => locale, 'steam.locale_in_path' => locale_in_path)
    env['steam.request'] = Rack::Request.new(env)
    code, env = middleware.call(env)
    [code, env['Location']]
  end

  describe 'not prefixed by locale' do

    describe 'strip default locale from root path' do
      let(:url) { 'http://models.example.com/de' }
      it { is_expected.to eq [301, '/'] }
    end

    describe 'strip default locale' do
      let(:url) { 'http://models.example.com/de/hello' }
      it { is_expected.to eq [301, '/hello'] }
    end

    describe 'strip default locale from root path with query' do
      let(:url) { 'http://models.example.com/de?this=is_a_param' }
      it { is_expected.to eq [301, '/?this=is_a_param'] }
    end

    describe 'strip default locale from path with query' do
      let(:url) { 'http://models.example.com/de/hello?this=is_a_param' }
      it { is_expected.to eq [301, '/hello?this=is_a_param'] }
    end

    describe 'dont strip a non-default locale' do
      let(:locale)  { 'fr' }
      let(:url)     { 'http://models.example.com/fr/hello' }
      it { is_expected.to eq [200, nil] }
    end

    describe 'dont redirect URL without locale' do
      let(:locale)          { :de }
      let(:locale_in_path)  { false }
      let(:url) { 'http://models.example.com/hello' }
      it { is_expected.to eq [200, nil] }
    end

  end

  describe 'prefixed by locale' do

    let(:prefixed) { true }

    describe 'without locale' do

      let(:locale_in_path) { false }

      describe 'add default locale to root path' do
        let(:url) { 'http://models.example.com/' }
        it { is_expected.to eq [301, '/de'] }
      end

      describe 'add default locale to long path' do
        let(:url) { 'http://models.example.com/hello/world' }
        it { is_expected.to eq [301, '/de/hello/world'] }
      end

      describe 'add default locale to url with path and query' do
        let(:url) { 'http://models.example.com/hello/world?this=is_me' }
        it { is_expected.to eq [301, '/de/hello/world?this=is_me'] }
      end

    end

    describe 'with locale' do

      let(:locale_in_path) { true }

      describe 'dont add default locale if already present' do
        let(:url)    { 'http://models.example.com/de/hello/world' }
        it { is_expected.to eq [200, nil] }
      end

      describe 'dont add default locale to localized path' do
        let(:locale) { 'fr' }
        let(:url)    { 'http://models.example.com/fr/hello/world' }
        it { is_expected.to eq [200, nil] }
      end

    end

  end

end
