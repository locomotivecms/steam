require 'spec_helper'

require_relative '../../../lib/locomotive/steam/middlewares/thread_safe'
require_relative '../../../lib/locomotive/steam/middlewares/concerns/helpers'
require_relative '../../../lib/locomotive/steam/middlewares/encoded_link_redirection'

describe Locomotive::Steam::Middlewares::EncodedLinkRedirection do

  let(:url_finder)      { instance_double('UrlFinder') }
  let(:services)        { instance_double('Services', url_finder: url_finder) }
  let(:site)            { instance_double('Site') }
  let(:url)             { 'http://models.example.com' }
  let(:mounted_on)      { nil }
  let(:locomotive_path) { nil }
  let(:app)             { ->(env) { [200, env, 'app'] } }
  let(:middleware)      { described_class.new(app) }

  subject do
    env = env_for(url, 'PATH_INFO' => locomotive_path, 'steam.site' => site)
    env['steam.request']    = Rack::Request.new(env)
    env['steam.mounted_on'] = mounted_on
    env['steam.services']   = services
    env['locomotive.path']  = locomotive_path
    code, env = middleware.call(env)
    [code, env['location']]
  end

  describe 'no redirections' do

    it { is_expected.to eq [200, nil] }

  end

  describe 'valid encoded link' do

    let(:encoded_link) { 'eyJ0eXBlIjoiX2V4dGVybmFsIiwidmFsdWUiOiJodHRwczovL3d3dy5ub2NvZmZlZS5mciIsImxhYmVsIjpbImV4dGVybmFsIiwiaHR0cHM6Ly93d3cubm9jb2ZmZWUuZnIiXX0' }
    let(:locomotive_path) { "/_locomotive-link/#{encoded_link}" }

    context 'external url' do

      it 'redirects (302) to the url stored in the encoded link' do
        expect(url_finder).to receive(:decode_link).with('eyJ0eXBlIjoiX2V4dGVybmFsIiwidmFsdWUiOiJodHRwczovL3d3dy5ub2NvZmZlZS5mciIsImxhYmVsIjpbImV4dGVybmFsIiwiaHR0cHM6Ly93d3cubm9jb2ZmZWUuZnIiXX0').and_return({
          'type'    => 'external',
          'value'   => 'https://www.nocoffee.fr',
          'locale'  => 'fr'
        })
        expect(services).to receive(:locale=).with('fr')
        allow(url_finder).to receive(:url_for).and_return(['https://www.nocoffee.fr', false])
        is_expected.to eq [302, 'https://www.nocoffee.fr']
      end

    end

    context 'local page' do

      let(:mounted_on) { '/my_app' }

      it 'redirects (302) to the page stored in the encoded link' do
        expect(url_finder).to receive(:decode_link).with('eyJ0eXBlIjoiX2V4dGVybmFsIiwidmFsdWUiOiJodHRwczovL3d3dy5ub2NvZmZlZS5mciIsImxhYmVsIjpbImV4dGVybmFsIiwiaHR0cHM6Ly93d3cubm9jb2ZmZWUuZnIiXX0').and_return({
          'type'    => 'page',
          'value'   => '42',
          'locale'  => 'fr'
        })
        expect(services).to receive(:locale=).with('fr')
        allow(url_finder).to receive(:url_for).and_return(['/about-us', false])
        is_expected.to eq [302, '/my_app/about-us']
      end

    end

  end

end
