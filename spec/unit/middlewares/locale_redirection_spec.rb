require 'spec_helper'

require_relative '../../../lib/locomotive/steam/middlewares/thread_safe'
require_relative '../../../lib/locomotive/steam/middlewares/concerns/helpers'
require_relative '../../../lib/locomotive/steam/middlewares/locale_redirection'

describe Locomotive::Steam::Middlewares::LocaleRedirection do

  let(:site)            { instance_double('Site', prefix_default_locale: prefixed, default_locale: :de, locales: %w(de fr)) }
  let(:url)             { 'http://models.example.com' }
  let(:app)             { ->(env) { [200, env, 'app'] } }
  let(:middleware)      { Locomotive::Steam::Middlewares::LocaleRedirection.new(app) }
  let(:locale)          { 'de' }
  let(:locale_in_path)  { true }
  let(:mounted_on)      { nil }

  subject do
    env = env_for(url, 'steam.site' => site, 'steam.locale' => locale, 'steam.locale_in_path' => locale_in_path)
    env['steam.mounted_on'] = mounted_on
    env['steam.request']    = Rack::Request.new(env)
    env['steam.path']       = env['steam.request'].path_info.gsub(/\A#{mounted_on}/, '').gsub(/\A\/#{locale}/, '')
    code, env = middleware.call(env)
    [code, env['Location']]
  end

  describe 'prefix_default_locale is false' do

    let(:prefixed) { false }

    describe 'locale is not part of the path' do

      let(:locale_in_path)  { false }
      it { is_expected.to eq [200, nil] }

    end

    describe 'for seo purpose redirect to the path without the locale' do

      let(:url) { 'http://models.example.com/de/hello' }
      it { is_expected.to eq [301, '/hello'] }

    end

  end

  describe 'prefix_default_locale is true' do

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

      describe 'mounted_on is present' do
        let(:mounted_on) { '/mounted-on/somewhere' }
        let(:url) { 'http://models.example.com/mounted-on/somewhere/hello/world' }
        it { is_expected.to eq [301, '/mounted-on/somewhere/de/hello/world'] }
      end

      describe 'requesting sitemap.xml' do
        let(:url) { 'http://models.example.com/sitemap.xml' }
        it { is_expected.to eq [200, nil] }
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
