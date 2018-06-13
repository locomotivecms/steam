require 'spec_helper'

require_relative '../../../lib/locomotive/steam/middlewares/helpers'

describe Locomotive::Steam::Middlewares::Helpers do

  let(:middleware)  { Class.new { include Locomotive::Steam::Middlewares::Helpers } }
  let(:instance)    { middleware.new }

  describe '#make_local_path' do

    let(:mounted_on) { nil }
    let(:location) { '/foo/bar' }

    before { allow(instance).to receive(:mounted_on).and_return(mounted_on) }

    subject { instance.make_local_path(location) }

    it { is_expected.to eq '/foo/bar' }

    context 'mounted_on is not blank' do

      let(:mounted_on) { '/my_app' }

      it { is_expected.to eq '/foo/bar' }

      context 'path including mounted_on' do

        let(:location) { '/my_app/foo/bar' }

        it { is_expected.to eq '/foo/bar' }

      end

    end

  end

  describe '#redirect_to' do

    subject { instance.redirect_to(location)[1]['Location'] }

    context 'mounted_on is not blank' do

      before { allow(instance).to receive(:mounted_on).and_return('/my_app') }

      let(:location) { '/foo/bar' }
      it { is_expected.to eq '/my_app/foo/bar' }

      describe 'the location already includes mounted_on' do

        let(:location) { '/my_app/foo' }
        it { is_expected.to eq '/my_app/foo' }

      end

    end

  end

  describe '#params' do

    let(:url)             { 'http://models.example.com' }
    let(:app)             { ->(env) { [200, env, 'app'] } }
    let(:options)         { {} }

    before do
      env = env_for(url, options)
      env['steam.request'] = Rack::Request.new(env)
      allow(instance).to receive(:app).and_return(app)
      allow(instance).to receive(:env).and_return(env)
    end

    subject { instance.params }

    context 'from a GET' do

      let(:url) { 'http://models.example.com?foo=bar' }

      it { is_expected.to eq('foo' => 'bar') }

    end

    context 'from a GET (JSON)' do

      let(:url) { 'http://models.example.com/api.json?foo=bar' }

      it { is_expected.to eq('foo' => 'bar') }

    end

    context 'from the body of JSON POST request' do

      let(:input) { '{"foo": { "bar": 42 } }' }

      let(:options) { {
        method: 'POST',
        input:  input,
        'CONTENT_TYPE' => 'application/json'
      } }

      it { is_expected.to eq('foo' => { 'bar' => 42 }) }

      it 'builds a hash with indifferent access' do
        expect(subject[:foo][:bar]).to eq 42
      end

      context 'the JSON is invalid' do

        let(:input) { '{ a: 2 }' }

        it 'returns an empty hash' do
          is_expected.to eq({})
        end

      end

    end

  end

end
