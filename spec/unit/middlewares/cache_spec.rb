require 'spec_helper'

require_relative '../../../lib/locomotive/steam/middlewares/thread_safe'
require_relative '../../../lib/locomotive/steam/middlewares/concerns/helpers'
require_relative '../../../lib/locomotive/steam/middlewares/cache'

describe Locomotive::Steam::Middlewares::Cache do

  let(:now)             { DateTime.parse('2015/09/26 22:00:00') }
  let(:method)          { 'GET' }
  let(:code)            { 200 }
  let(:live_editing)    { nil }
  let(:published)       { true }
  let(:etag)            { nil }
  let(:url)             { 'http://models.example.com' }
  let(:path)            { 'hello-world' }
  let(:page)            { instance_double('Page') }
  let(:cache)           { instance_double('CacheService', ) }
  let(:app)             { ->(env) { [code, {}, ['Hello world!']] } }
  let(:middleware)      { described_class.new(app) }

  subject do
    env = send_request[:env]
    [env['steam.cache_control'], env['steam.cache_vary']]
  end

  describe 'caching is disabled for the site' do

    let(:site) { instance_double('Site', cache_enabled: false) }

    it 'tells the the CDN to not cache the page' do
      is_expected.to eq ['max-age=0, private, must-revalidate', nil]
    end

  end

  describe 'caching is disabled for the page' do

    let(:site) { instance_double('Site', cache_enabled: true) }
    let(:page) { instance_double('Page', cache_enabled: false) }

    it 'tells the the CDN to not cache the page' do
      is_expected.to eq ['max-age=0, private, must-revalidate', nil]
    end

  end

  describe 'the caching is enabled for the page' do

    let(:site) { instance_double('Site', _id: 42, last_modified_at: now, cache_enabled: true) }
    let(:page) { instance_double('Page', cache_enabled: true) }

    context 'the request is a GET' do

      let(:response) { nil }

      before { expect(cache).to receive(:read).with('2aa324a4ee6159cedf46c5c850d965b1').and_return(response) }

      context 'the cache is empty' do

        before { expect(cache).to receive(:write).with('2aa324a4ee6159cedf46c5c850d965b1', Marshal.dump([200, {}, ["Hello world!"]])) }

        it 'tells the CDN to cache the page and also cache it internally' do
          is_expected.to eq ['max-age=0, s-maxage=3600, public, must-revalidate', 'Accept-Language']
        end

        describe 'ETag' do

          subject { send_request[:env]['steam.cache_etag'] }

          it { is_expected.to eq '2aa324a4ee6159cedf46c5c850d965b1' }

        end

        describe 'the site administrator sets a custom cache control and vary' do

          let(:site) { instance_double('Site', _id: 42, last_modified_at: now, cache_enabled: true, cache_control: 'max-age=600, s-maxage=600, public, must-revalidate', cache_vary: 'Cookie') }

          it 'tells the CDN to cache the page with the custom cache control' do
            is_expected.to eq ['max-age=600, s-maxage=600, public, must-revalidate', 'Cookie']
          end

        end

      end

      describe 'the cache contains the response' do

        let(:response) { Marshal.dump([200, {}, ["Hello world!"]]) }

        it 'tells the CDN to cache the page' do
          expect(cache).not_to receive(:write)
          is_expected.to eq ['max-age=0, s-maxage=3600, public, must-revalidate', 'Accept-Language']
        end

      end

    end

    describe 'the page has not been modified for a while' do

      let(:etag) { '2aa324a4ee6159cedf46c5c850d965b1' }

      subject { [send_request[:code], send_request[:headers]] }

      it 'returns a 304 (Not modified) without no cache headers' do
        expect(subject.first).to eq 304
        expect(subject.last['Cache-Control']).to eq nil
      end

    end

    context 'the request is a POST' do

      let(:method) { 'POST' }

      it 'tells the the CDN to not cache the page' do
        is_expected.to eq ['max-age=0, private, must-revalidate', nil]
      end

    end

    context 'the response is a redirection (302)' do

      let(:code) { 302 }

      before do
        allow(cache).to receive(:read).and_return(nil)
        allow(cache).to receive(:write).and_return(true)
      end

      it 'tells the the CDN to not cache the page' do
        is_expected.to eq ['max-age=0, private, must-revalidate', nil]
      end

    end

    context 'the live editing mode is on' do

      let(:live_editing) { true }

      it 'tells the the CDN to not cache the page' do
        is_expected.to eq ['max-age=0, private, must-revalidate', nil]
      end

    end

  end

  def send_request
    env = env_for(url,
      method:               method,
      'If-None-Match'       => etag,
      'steam.site'          => site,
      'steam.page'          => page,
      'steam.path'          => path,
      'steam.locale'        => 'en',
      'steam.live_editing'  => live_editing,
      'steam.services'      => instance_double('Services', cache: cache)
    )

    env['steam.request'] = Rack::Request.new(env)

    code, headers, body = middleware.call(env)

    { env: env, code: code, headers: headers }
  end

end
