require 'spec_helper'

describe Locomotive::Steam::Models::Repository do

  let(:adapter)     { nil }
  let(:site)        { nil }
  let(:locale)      { :en }
  let(:repository)  { ArticleRepository.new(adapter, site, locale) }

  describe '#locale' do

    subject { repository.locale }

    it { is_expected.to eq :en }

    context 'change the locale' do

      before { repository.locale = :fr }

      it { is_expected.to eq :fr }

    end

  end

  describe '#scope' do

    subject { repository.scope }

    it { expect(subject.locale).to eq :en }

    context 'change the locale from the repository' do

      before { subject; repository.locale = :fr }

      it { expect(subject.locale).to eq :fr }

    end

  end

  class ArticleRepository
    include Locomotive::Steam::Models::Repository
  end

end
