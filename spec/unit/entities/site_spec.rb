require 'spec_helper'

describe Locomotive::Steam::Site do

  let(:attributes) { {} }
  let(:site) { described_class.new(attributes) }

  describe '#handle' do

    let(:attributes) { { handle: 'acme' } }

    subject { site.handle }
    it { is_expected.to eq 'acme' }

    context 'from a subdomain if the handle property is nil' do

      let(:attributes) { { subdomain: 'acme' } }
      it { is_expected.to eq 'acme' }

    end

  end

  describe '#locales' do

    let(:attributes) { { locales: %w(en fr) } }

    subject { site.locales }
    it { is_expected.to eq [:en, :fr] }

  end

  describe '#default_locale' do

    let(:attributes) { { locales: %w(en fr) } }

    subject { site.default_locale }
    it { is_expected.to eq :en }

  end

  describe '#timezone_name' do

    subject { site.timezone_name }
    it { is_expected.to eq 'UTC' }

    context 'not blank' do

      let(:attributes) { { timezone: 'CDT' } }
      it { is_expected.to eq 'CDT' }

    end

    context 'from the timezone_name attribute itself' do

      let(:attributes) { { timezone_name: 'CDT' } }
      it { is_expected.to eq 'CDT' }

    end

  end

  describe '#last_modified_at' do

    subject { site.last_modified_at }

    it { is_expected.to eq nil }

    context 'only updated_at is defined' do

      let(:attributes) { { updated_at: DateTime.parse('2015/10/16 00:00:00') } }
      it { is_expected.to eq DateTime.parse('2015/10/16 00:00:00') }

    end

    context 'template_version or content_version are defined' do

      let(:attributes) { { updated_at: DateTime.parse('2015/10/16 00:00:00'), template_version: DateTime.parse('2007/06/29 00:00:00'), content_version: DateTime.parse('2009/09/10 00:00:00') } }
      it { is_expected.to eq DateTime.parse('2009/09/10 00:00:00') }

    end

  end

end
