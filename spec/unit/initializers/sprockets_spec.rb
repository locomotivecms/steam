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

  describe '#install_autoprefixer' do

    subject { env }

    context "config/autoprefixer.yml doesn't exist" do

      before { allow(File).to receive(:exists?).and_return false }

      it { expect(AutoprefixerRails).not_to receive(:install); subject }

    end

    context "config/autoprefixer.yml exists" do

      before {
        allow(File).to receive(:exists?).and_return(true)
        allow(YAML).to receive(:load_file).and_return({})
      }

      it { expect(AutoprefixerRails).to receive(:install).and_return(true); subject }

    end

  end

end
