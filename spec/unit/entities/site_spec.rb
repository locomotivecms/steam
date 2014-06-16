require 'spec_helper'

describe 'Locomotive::Steam::Entities::Site' do

  describe '#default_locale' do
    subject { Locomotive::Steam::Entities::Site.new attributes }
    let(:attributes) { { locales: [:wk, :fr, :es] } }
    it 'uses the first locale as default locale' do
      expect(subject.default_locale).to eq :wk
    end
  end
end
