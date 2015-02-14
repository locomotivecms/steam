require 'spec_helper'

describe Locomotive::Steam::Repositories::Filesystem::Models::Page do

  let(:attributes) { {} }
  let(:page) { Locomotive::Steam::Repositories::Filesystem::Models::Page.new(attributes) }

  describe '#not_found' do

    let(:attributes) { { fullpath: { en: 'index' } } }

    subject { page.not_found? }
    it { is_expected.to eq false }

    context 'true' do
      let(:attributes) { { fullpath: { en: '404' } } }
      it { is_expected.to eq true }
    end

  end

end
