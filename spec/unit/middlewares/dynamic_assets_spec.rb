require 'spec_helper'

require_relative '../../../lib/locomotive/steam/middlewares/dynamic_assets'

describe Locomotive::Steam::Middlewares::DynamicAssets do

  let(:app)         { ->(env) { [200, env, 'app'] }}
  let(:options)     { { root: File.dirname(__FILE__), minify: true } }
  let(:middleware)  { described_class.new(app, options) }

  describe '#call' do

    let(:env) { { 'PATH_INFO' => '/stylesheets/application.css' } }
    subject { middleware.call(env) }

    it 'calls sprockets to process the asset' do
      expect(middleware.assets).to receive(:call).with(env).and_return(true)
      is_expected.to eq true
    end

    context 'not an asset' do

      let(:env) { { 'PATH_INFO' => '/index' } }

      it 'bypasses sprockets' do
        expect(middleware.assets).not_to receive(:call)
        is_expected.not_to eq nil
      end

    end

  end

end
