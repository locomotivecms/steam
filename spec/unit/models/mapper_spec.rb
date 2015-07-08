require 'spec_helper'

describe Locomotive::Steam::Models::Mapper do

  let(:adapter)     { instance_double('Adapter') }
  let(:scope)       { instance_double('SimpleScope', apply: true) }
  let(:repository)  { instance_double('Repository', scope: scope, base_url: '') }
  let(:name)        { 'pages' }
  let(:options)     { { entity: MyPage } }
  let(:block)       { nil }
  let(:mapper)      { described_class.new(name, options, repository, &block) }

  describe '#localized attributes' do

    let(:block) { ->(_) { localized_attributes(:foo, :bar) } }

    subject { mapper.localized_attributes }
    it { is_expected.to eq [:foo, :bar] }

  end

  describe '#serialize' do

    let(:options) { { entity: MyArticle } }
    let(:attributes) { { title: 'Hello world', body: 'Lorem ipsum', published_at: DateTime.parse('2007/06/29 00:00:00') } }
    let(:entity) { mapper.to_entity(attributes) }

    subject { mapper.serialize(entity) }

    it { expect(subject).to eq('title' => 'Hello world', 'body' => 'Lorem ipsum', 'published_at' => DateTime.parse('2007/06/29 00:00:00')) }

    describe 'association' do

      let(:repository)  { instance_double('AuthorRepository', scope: scope, adapter: adapter, base_url: '') }

      describe 'belongs_to' do

        let(:block) { ->(_) { belongs_to_association(:author, BlankRepository) } }

        context 'no object' do

          let(:attributes) { { author_id: nil } }

          it { expect(subject).to eq('author_id' => nil) }

        end

        context 'existing object' do

          before { entity.author = instance_double('Author', _id: 1) }

          it { expect(subject).to eq('title' => 'Hello world', 'author_id' => 1, 'body' => 'Lorem ipsum', 'published_at' => DateTime.parse('2007/06/29 00:00:00')) }

        end

      end

      describe 'many_to_many' do

        let(:block) { ->(_) { many_to_many_association(:authors, BlankRepository) } }

        context 'no object' do

          let(:attributes) { { author_ids: nil } }

          it { expect(subject).to eq('author_ids' => nil) }

        end

        context 'existing object' do

          before { entity.authors = [instance_double('Author', _id: 1), instance_double('Author', _id: 2)] }

          it { expect(subject).to eq('title' => 'Hello world', 'author_ids' => [1, 2], 'body' => 'Lorem ipsum', 'published_at' => DateTime.parse('2007/06/29 00:00:00')) }

        end

      end

    end

  end

  describe '#to_entity' do

    subject { mapper.to_entity(attributes) }

    describe 'default attributes' do

      let(:attributes) { { title: 'Hello world' } }
      let(:repository) { instance_double('Repository', my_site: 42, base_url: '') }
      let(:block) { ->(_) { default_attribute(:site, -> (repository) { repository.my_site }) } }

      it { expect(subject.site).to eq 42 }

    end

    describe 'association' do

      let(:repository)  { instance_double('Repository', scope: 42, base_url: '') }
      let(:attributes) { { parents: [instance_double('Page', title: 'Hello world')] } }
      let(:klass) { instance_double('RepositoryKlass')}
      let(:block) { ->(_) { embedded_association(:parents, BlankRepository) } }

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

  class MyArticle
    include Locomotive::Steam::Models::Entity
    attr_accessor :site
  end

  class BlankRepository < Struct.new(:adapter)
    attr_accessor :page, :scope
  end

end
