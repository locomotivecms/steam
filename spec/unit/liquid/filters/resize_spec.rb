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

    describe 'additional filters' do
      let(:geometry) { '30x40#' }
      subject {}

      before do
        @context.registers[:services].image_resizer = instance_spy('ImageResizerService')
        @image_resizer = @context.registers[:services].image_resizer
      end

      it 'handles quality' do
        resize(input, geometry, { "quality" => 70 })
        expect(@image_resizer).to have_received(:resize).with(input, geometry, "-quality 70")
      end

      it 'handles auto_orient' do
        resize(input, geometry, { "auto_orient" => true })
        expect(@image_resizer).to have_received(:resize).with(input, geometry, "-auto-orient")
      end

      it "doesn't auto_orient if false" do
        resize(input, geometry, { "auto_orient" => false })
        expect(@image_resizer).to have_received(:resize).with(input, geometry, "")
      end

      it 'handles optimize' do
        resize(input, geometry, { "optimize" => 75 })
        expect(@image_resizer).to have_received(:resize).with(input, geometry, "-quality 75 -strip -interlace Plane")
      end

      it 'handles multiple and custom filters' do
        resize(input, geometry, { "quality" => 60, "filters" => "-sepia-tone 80%" })
        expect(@image_resizer).to have_received(:resize).with(input, geometry, "-quality 60 -sepia-tone 80%")
      end
    end

  end

end
