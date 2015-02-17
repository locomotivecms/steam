require 'spec_helper'

require 'sprockets'
require_relative '../../../lib/locomotive/steam/middlewares/dynamic_assets'

describe Locomotive::Steam::Middlewares::DynamicAssets do

  let(:app)     { ->(env) { [200, env, 'app'] }}
  let(:options) { { root: File.dirname(__FILE__), minify: true } }

  let(:middleware) { Locomotive::Steam::Middlewares::DynamicAssets.new(app, options) }

  describe 'java not installed' do

    let(:sprockets) { instance_double('Sprockets') }

    before { allow(middleware).to receive(:is_java_installed?).and_return(false) }

    subject { middleware.send(:install_yui_compressor, sprockets, options) }

    it { is_expected.to eq(false) }

  end

end
