require 'spec_helper'

describe Locomotive::Steam::Liquid::Filters::Misc do

  include Locomotive::Steam::Liquid::Filters::Base

  describe '#absolute_url' do

    subject { absolute_url(url) }

    context 'absolute url' do

      let(:url) { 'http://www.locomotive.works/themes/background.png' }

      it { is_expected.to eq 'http://www.locomotive.works/themes/background.png' }

    end

    context 'relative url' do

      before { @context = { 'base_url' => 'http://www.locomotive.works' } }

      let(:url) { 'themes/background.png' }

      it { is_expected.to eq 'http://www.locomotive.works/themes/background.png' }

    end

  end

end
