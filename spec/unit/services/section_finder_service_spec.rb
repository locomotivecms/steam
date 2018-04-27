require 'spec_helper'

describe Locomotive::Steam::SectionFinderService do

  let(:repository) { instance_double('SectionRepository') }
  let(:site) { instance_double('Site', _id: 1, default_locale: :en, locales: [:en, :fr])
  let(:section) { instance_double('Section') }
  let(:slug) { 'header' }

  let(:finder) { described_class.new repository }

  before do
    allow(repository).to receive(:by_slug).and_return(section)
    allow(repository).to receive(:locale).and_return(:en)
    allow(repository).to receive(:site).and_return(site)
    allow(section).to receive(:localized_attributes).and_return(nil)
  end

  describe '#find' do

    subject { finder.find(slug) }

    it { is_expected.to respond_with section }

  end
end

