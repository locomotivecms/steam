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

  describe '#prepare_conditions' do

    let(:conditions) { [{ 'band_id' => 42, 'order_by' => 'created_at.desc' }] }

    subject { repository.prepare_conditions(*conditions) }

    it { is_expected.to eq({ 'band_id' => 42, 'order_by' => 'created_at.desc' }) }

    context 'with local conditions' do

      let(:local_conditions) { { parent_id: 1, order_by: { position: 'asc' } } }

      before { repository.local_conditions = local_conditions }

      it { is_expected.to eq({ 'parent_id' => 1, 'band_id' => 42, 'order_by' => 'created_at.desc' }) }

      it "doesn't modify the local conditions" do
        subject
        expect(local_conditions).to eq({ parent_id: 1, order_by: { position: 'asc' } })
      end

    end

  end

  class ArticleRepository
    include Locomotive::Steam::Models::Repository
  end

end
