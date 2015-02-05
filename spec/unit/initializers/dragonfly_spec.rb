require 'spec_helper'

describe Locomotive::Steam::Initializers::Dragonfly do

  let(:initializer) { Locomotive::Steam::Initializers::Dragonfly.new }

  subject { ::Dragonfly.app(:steam).plugins[:imagemagick] }

  describe 'with ImagickMagick' do

    before { initializer.run }
    it { is_expected.not_to eq nil }

  end

  describe 'missing ImagickMagick' do

    before do
      ::Dragonfly::App.destroy_apps
      expect(File).to receive(:exists?).and_return(false)
      initializer.run
    end
    it { is_expected.to eq nil }

    after(:all) do
      Locomotive::Steam::Initializers::Dragonfly.new.run
    end

  end

end
