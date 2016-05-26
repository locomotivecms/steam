require 'spec_helper'

describe Locomotive::Steam::Decorators::PageDecorator do

  let(:redirect)        { nil }
  let(:redirect_url)    { nil }
  let(:page)            { instance_double('Page', localized_attributes: [], redirect: redirect, redirect_url: redirect_url) }
  let(:locale)          { 'fr' }
  let(:default_locale)  { 'en' }
  let(:decorated)       { described_class.new(page, locale, default_locale) }

  describe '#redirect?' do

    subject { decorated.redirect? }

    it { is_expected.to eq false }

    context 'redirect_url has been set' do

      let(:redirect_url) { 'http://www.google.fr' }

      it { is_expected.to eq true }

      context 'but redirect is set to false' do

        let(:redirect) { false }

        it { is_expected.to eq false }

      end

    end

  end

end
