require 'spec_helper'

describe Locomotive::Steam::ImageResizerService do

  let(:resizer) { nil }
  let(:path)    { nil }
  let(:service) { described_class.new(resizer, path) }

  describe '#resize' do

    let(:geometry)  { '400x30#' }
    let(:input)     { 'http://upload.wikimedia.org/wikipedia/en/thumb/b/b5/Metropolitan_railway_steam_locomotive_2781022036.png/240px-Metropolitan_railway_steam_locomotive_2781022036.png' }

    subject { service.resize(input, geometry) }

    describe 'no resizer' do
      it { is_expected.to eq nil }
    end

    describe 'DragonFly' do

      let(:resizer) { Dragonfly.app(:steam) }

      describe 'no imagemagick' do
        before { expect(resizer.plugins).to receive(:[]).with(:imagemagick).and_return(nil) }
        it { is_expected.to eq nil }
      end

      describe 'no geometry' do
        let(:geometry) { '' }
        it { is_expected.to eq nil }
      end

      it { is_expected.to match /images\/dynamic\/.*\/240px-Metropolitan_railway_steam_locomotive_2781022036.png/ }

      describe 'a local asset' do

        let(:input)  { '/sites/42/theme/images/banner.png' }
        it { is_expected.to match /images\/dynamic\/.*\/banner.png/ }

      end

      describe 'a hash' do

        let(:input) { { 'url' => '/sites/42/theme/images/banner.png' } }
        it { is_expected.to match /images\/dynamic\/.*\/banner.png/ }

      end

      describe 'an object responding to the url method (Carrierwave uploaded file)' do

        let(:input)  { instance_double('UploadedFile', url: '/sites/42/theme/acme.png') }
        it { is_expected.to match /images\/dynamic\/.*\/acme.png/ }

      end

      describe 'an url with a timestamp' do

        let(:input)  { '/sites/42/theme/images/banner.png?24e29997bcb00e97d8252cdd29d14e2d' }
        it { is_expected.to match /images\/dynamic\/.*\/banner.png\?sha=[a-z0-9]+/ }

      end

      describe 'unable to fetch a file' do

        before { allow(service).to receive(:fetch_file).and_return(nil) }
        it { is_expected.to eq nil }

      end

    end

  end

end
