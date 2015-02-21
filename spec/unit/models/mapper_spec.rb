require 'spec_helper'

describe Locomotive::Steam::Models::Mapper do

  let(:name)    { 'pages' }
  let(:options) { { entity: MyPage } }
  let(:block)   { nil }
  let(:mapper)  { Locomotive::Steam::Models::Mapper.new(name, options, &block) }

  describe '#localized attributes' do

    let(:block) { ->(_) { set_localized_attributes(:foo, :bar) } }

    subject { mapper.localized_attributes }
    it { is_expected.to eq [:foo, :bar] }

  end

  describe '#to_entity' do

    let(:block) { ->(_) { set_localized_attributes(:title) } }
    let(:attributes) { { title: { 'en' => 'Hello world' } } }

    subject { mapper.to_entity(attributes) }
    it { expect(subject.attributes[:title].class).to eq Locomotive::Steam::Models::I18nField }
    it { expect(subject.attributes[:title][:en]).to eq('Hello world') }

    context 'string value for the localized field' do

      let(:attributes) { { title: 'Hello world' } }

      it { expect(subject.attributes[:title][:en]).to eq('Hello world') }
      it { expect(subject.attributes[:title][:fr]).to eq('Hello world') }

    end

  end

  class MyPage < Struct.new(:attributes); end

end
