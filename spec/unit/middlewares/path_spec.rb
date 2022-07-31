require 'spec_helper'

require_relative '../../../lib/locomotive/steam/middlewares/path'

describe Locomotive::Steam::Middlewares::Path do

  let(:allow_dots_in_slugs) { false }
  let(:site)            { instance_double('Site', allow_dots_in_slugs: allow_dots_in_slugs) }
  let(:routes)          { {} }
  let(:url)             { 'http://models.example.com' }
  let(:path)            { 'hello-world' }
  let(:app)             { ->(env) { [200, env, 'app'] } }
  let(:middleware)      { described_class.new(app) }

  subject do
    env = env_for(url, 'steam.site' => site)
    env['steam.path']         = path
    env['steam.locale']       = 'en'
    env['steam.request']      = Rack::Request.new(env)
    code, env = middleware.call(env)
    env['steam.path']
  end

  describe 'allow_dots_in_slugs is off' do
    context 'html extension' do
      let(:path) { 'foo.html' }
      it { is_expected.to eq 'foo' }
    end

    context 'the path stores a version' do
      let(:path) { 'foo-v1.0' }
      it { is_expected.to eq 'foo-v1.0' }
    end

    context 'prefixed by 3 letters word' do
      let(:path) { 'foo.bar' }
      it { is_expected.to eq 'foo' }  
    end

    context 'starting by a dot' do
      let(:path) { '.well-known' }
      it { is_expected.to eq '.well-known' }  
    end
  end

  describe 'allow_dots_in_slugs is on' do
    let(:allow_dots_in_slugs) { true }

    context 'html extension' do
      let(:path) { 'foo.html' }
      it { is_expected.to eq 'foo' }
    end

    context 'prefixed by a version' do
      let(:path) { 'foo-v1.0' }
      it { is_expected.to eq 'foo-v1.0' }  
    end

    context 'prefixed by 3 letters word' do
      let(:path) { 'foo.bar' }
      it { is_expected.to eq 'foo.bar' }  
    end

    context 'starting by a dot' do
      let(:path) { '.well-known' }
      it { is_expected.to eq '.well-known' }  
    end
  end

end
