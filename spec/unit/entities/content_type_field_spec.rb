require 'spec_helper'

describe Locomotive::Steam::ContentTypeField do

  let(:attributes)    { { name: 'title', type: 'string' } }
  let(:field)         { described_class.new(attributes) }

  describe '#type' do

    subject { field.type }
    it { is_expected.to eq :string }

  end

  describe '#order_by' do

    subject { field.order_by }
    it { is_expected.to eq nil }

    context 'has_many field' do

      let(:attributes) { { name: 'articles', type: 'has_many', inverse_of: 'author' } }
      it { is_expected.to eq(position_in_author: 'asc') }

      context 'order_by is specified' do

        let(:attributes) { { name: 'articles', type: 'has_many', inverse_of: 'author', order_by: 'name asc' } }
        it { is_expected.to eq(name: 'asc') }

      end

    end

  end

  describe '#target_id' do

    subject { field.target_id }
    it { is_expected.to eq nil }

    context 'slug' do

      let(:attributes) { { name: 'articles', class_name: 'articles' } }
      it { is_expected.to eq 'articles' }

    end

    context 'class name' do

      let(:attributes) { { name: 'articles', class_name: 'Locomotive::ContentEntry42' } }
      it { is_expected.to eq '42' }

    end

  end

  describe '#association_options' do

    let(:attributes) { { name: 'articles', class_name: 'articles', type: 'has_many', inverse_of: 'author' } }

    subject { field.association_options }

    it { is_expected.to eq(target_id: 'articles', inverse_of: 'author', order_by: { position_in_author: 'asc' }) }

  end

  describe '#is_relationship?' do

    let(:attributes) { { name: 'articles', class_name: 'articles', type: 'has_many', inverse_of: 'author' } }

    subject { field.is_relationship? }

    it { is_expected.to eq true }

  end

  describe '#persisted_name' do

    subject { field.persisted_name }

    context 'string type' do

      let(:attributes) { { name: 'title', type: 'string' } }
      it { is_expected.to eq 'title' }

    end

    context 'select type' do

      let(:attributes) { { name: 'category', type: 'select' } }
      it { is_expected.to eq 'category_id' }

    end

    context 'belongs_to type' do

      let(:attributes) { { name: 'article', class_name: 'articles', type: 'belongs_to' } }
      it { is_expected.to eq 'article_id' }

    end

    context 'many_to_many type' do

      let(:attributes) { { name: 'articles', class_name: 'articles', type: 'many_to_many' } }
      it { is_expected.to eq 'article_ids' }

    end

    context 'has_many type' do

      let(:attributes) { { name: 'articles', class_name: 'articles', type: 'has_many', inverse_of: 'author' } }
      it { is_expected.to eq nil }

    end

  end

end
