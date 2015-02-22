require 'spec_helper'

describe Locomotive::Steam::Models::Mapper do

  let(:repository)  { instance_double('Repository') }
  let(:name)        { 'pages' }
  let(:options)     { { entity: MyPage } }
  let(:block)       { nil }
  let(:mapper)      { Locomotive::Steam::Models::Mapper.new(name, options, repository, &block) }

  describe '#localized attributes' do

    let(:block) { ->(_) { localized_attributes(:foo, :bar) } }

    subject { mapper.localized_attributes }
    it { is_expected.to eq [:foo, :bar] }

  end

  describe '#to_entity' do

    subject { mapper.to_entity(attributes) }

    describe 'default attributes' do

      let(:attributes) { { title: 'Hello world' } }
      let(:repository) { instance_double('Repository', my_site: 42) }
      let(:block) { ->(_) { default_attribute(:site, -> (repository) { repository.my_site }) } }

      it { expect(subject.site).to eq 42 }

    end

    describe 'association' do

      let(:attributes) { { parents: [instance_double('Page', title: 'Hello world')] } }
      let(:klass) { instance_double('RepositoryKlass')}
      let(:block) { ->(_) { association(:parents, BlankRepository) } }

      it { expect(subject.parents).not_to eq nil }

    end

    describe 'localized attributes' do

      let(:block) { ->(_) { localized_attributes(:title) } }
      let(:attributes) { { title: { 'en' => 'Hello world' } } }

      it { expect(subject.attributes[:title].class).to eq Locomotive::Steam::Models::I18nField }
      it { expect(subject.attributes[:title][:en]).to eq('Hello world') }

      context 'string value for the localized field' do

        let(:attributes) { { title: 'Hello world' } }

        it { expect(subject.attributes[:title][:en]).to eq('Hello world') }
        it { expect(subject.attributes[:title][:fr]).to eq('Hello world') }

      end

    end

  end

  class MyPage
    include Locomotive::Steam::Models::Entity
    attr_accessor :site
  end

  class BlankRepository < Struct.new(:adapter)
    attr_accessor :parent
  end

end
