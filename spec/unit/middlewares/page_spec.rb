require 'spec_helper'

require_relative '../../../lib/locomotive/steam/middlewares/thread_safe'
require_relative '../../../lib/locomotive/steam/middlewares/concerns/helpers'
require_relative '../../../lib/locomotive/steam/middlewares/page'

describe Locomotive::Steam::Middlewares::Page do

  let(:live_editing)    { nil }
  let(:published)       { true }
  let(:page_not_found)  { instance_double('PageNotFound', not_found?: true) }
  let(:page)            { instance_double('Page', title: 'Hello world', fullpath: 'hello-world', not_found?: false, published?: published) }
  let(:pages)           { [page] }
  let(:site)            { instance_double('Site', default_locale: 'en', routes: routes) }
  let(:service)         { instance_double('PageFinder', match: pages) }
  let(:routes)          { {} }
  let(:url)             { 'http://models.example.com' }
  let(:path)            { 'hello-world' }
  let(:app)             { ->(env) { [200, env, 'app'] } }
  let(:middleware)      { described_class.new(app) }

  subject do
    env = env_for(url, 'steam.site' => site)
    env['steam.path']         = path
    env['steam.locale']       = 'en'
    env['steam.live_editing'] = live_editing
    env['steam.request']      = Rack::Request.new(env)
    code, env = middleware.call(env)
    [env['steam.page'], env['steam.request'].params]
  end

  before do
    allow_any_instance_of(described_class).to receive(:page_finder).and_return(service)
    allow(service).to receive(:find).with('404').and_return(page_not_found)
  end

  describe 'named route' do

    let(:path)    { 'posts/2018/09' }
    let(:routes)  { [{ 'route' => '/posts/:year', 'page_handle' => 'posts' }, { 'route' => '/posts/:year/:month', 'page_handle' => 'posts' }] }

    it 'returns the page based on the handle returned by the routing hash' do
      expect(service).to receive(:by_handle).with('posts', false).and_return(page)
      is_expected.to eq([page, { 'year' => '2018', 'month' => '09' }])
    end

    describe 'wrong route syntax' do

      let(:routes)  { [{ 'route' => '/posts/:_year/:month', 'page_handle' => 'posts' }] }

      it "doesn't match the route" do
        is_expected.to eq([page, {}])
      end

    end

    describe 'path with a dash' do

      let(:path)    { 'resources/hello-world' }
      let(:routes)  { [{ 'route' => '/resources/:slug', 'page_handle' => 'resources' }] }

      it 'returns the page based on the handle returned by the routing hash' do
        expect(service).to receive(:by_handle).with('resources', false).and_return(page)
        is_expected.to eq([page, { 'slug' => 'hello-world' }])
      end


    end

  end

  describe 'a page outside the site routes' do

    it { is_expected.to eq([page, {}]) }

    context "page doesn't exist" do

      let(:pages) { [] }

      it { is_expected.to eq([page_not_found, {}]) }

    end

    context 'page is unpublished' do

      let(:published) { false }

      it { is_expected.to eq([page_not_found, {}]) }

      context 'the live editing mode is on' do

        let(:live_editing) { true }

        it 'has to display it' do
          is_expected.to eq([page, {}])
        end

      end

    end

  end

end
