require 'spec_helper'

require_relative '../../../lib/locomotive/steam/initializers/sprockets'

describe Locomotive::Steam::SprocketsEnvironment do

  let(:root)    { '.' }
  let(:options) { { minify: true } }
  let(:env)     { described_class.new(root, options) }

  describe '#install_yui_compressor' do

    context 'java not installed' do

      before { allow(env).to receive(:is_java_installed?).and_return(false) }

      subject { env.send(:install_yui_compressor, options) }

      it { is_expected.to eq(false) }

    end

  end

end
