require 'spec_helper'

describe Locomotive::Steam::Liquid::Filters::Resize do

  include Locomotive::Steam::Liquid::Filters::Resize

  let(:services)  { Locomotive::Steam::Services.build_instance }
  let(:context)   { instance_double('Context', registers: { services: services }) }
  let(:input)     { '' }
  let(:geometry)  { nil }

  subject { resize(input, geometry) }

  before { @context = context }

  it { is_expected.to eq '' }

  describe 'with an url' do

    let(:input) { 'http://upload.wikimedia.org/wikipedia/en/thumb/b/b5/Metropolitan_railway_steam_locomotive_2781022036.png/240px-Metropolitan_railway_steam_locomotive_2781022036.png' }

    it 'returns the input' do
      is_expected.to eq 'http://upload.wikimedia.org/wikipedia/en/thumb/b/b5/Metropolitan_railway_steam_locomotive_2781022036.png/240px-Metropolitan_railway_steam_locomotive_2781022036.png'
    end

    describe 'with a geometry' do

      let(:geometry) { '30x40#' }

      it { is_expected.to match /\/steam\/dynamic\/.*\/240px-Metropolitan_railway_steam_locomotive_2781022036.png/ }

      describe 'when imagemagick is not available' do

        let(:input) {
          double('image from liquid', url: 'http://upload.wikimedia.org/wikipedia/en/thumb/b/b5/Metropolitan_railway_steam_locomotive_2781022036.png/240px-Metropolitan_railway_steam_locomotive_2781022036.png')
        }

        before do
          image_resizer = @context.registers[:services].image_resizer
          allow(image_resizer).to receive(:disabled?).and_return(true)
        end

        it 'returns the original url without resizing' do
          is_expected.to eq 'http://upload.wikimedia.org/wikipedia/en/thumb/b/b5/Metropolitan_railway_steam_locomotive_2781022036.png/240px-Metropolitan_railway_steam_locomotive_2781022036.png'
        end

      end

    end

  end

end
