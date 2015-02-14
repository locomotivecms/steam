require 'spec_helper'

describe Locomotive::Steam::Repositories::Filesystem::ContentEntry do

  # let(:fields)  { [{ title: { hint: 'Title of the article' } }, { author: { type: 'string', label: 'Fullname of the author' } }] }
  let(:type)    { instance_double('Articles', slug: 'articles', order_by: nil, label_field_name: :title, localized_fields_names: [:title], fields_by_name: { title: instance_double('Field', name: :title, type: :string) }) }
  let(:loader)  { instance_double('Loader', list_of_attributes: [{ content_type: type, _position: 0, _label: 'Update #1', title: { fr: 'Mise a jour #1' }, text: { en: 'added some free stuff', fr: 'phrase FR' }, date: '2009/05/12', category: 'General' }]) }
  let(:site)    { instance_double('Site', default_locale: :en, locales: [:en, :fr]) }
  let(:locale)  { :en }

  let(:content_type_repository) { instance_double('ContentTypeRepository') }
  let(:repository) { Locomotive::Steam::Repositories::Filesystem::ContentEntry.new(loader, site, locale, content_type_repository) }

  describe '#collection' do

    subject { repository.send(:collection, type) }

    it { expect(subject.size).to eq 1 }

    describe 'once after the sanitizer has been applied' do

      subject { repository.send(:collection, type).first }

      it { expect(subject.class).to eq Locomotive::Steam::Repositories::Filesystem::Models::ContentEntry }
      it { expect(subject.title).to eq({ en: 'Update #1', fr: 'Mise a jour #1' }) }
      it { expect(subject._slug).to eq({ en: 'update-1', fr: 'mise-a-jour-1' }) }
      it { expect(subject.content_type).to eq type }

    end

  end

  describe '#by_slug' do

    let(:slug) { nil }
    subject { repository.by_slug(type, slug) }

    it { is_expected.to eq nil }

    context 'existing slug' do
      let(:slug) { 'update-1' }
      it { expect(subject.title).to eq({ en: 'Update #1', fr: 'Mise a jour #1' }) }
    end

  end

  describe '#value_for' do

    let(:name)    { :title }
    let(:entry)   { instance_double('Article', title: 'Hello world') }

    subject { repository.value_for(name, entry) }

    it { is_expected.to eq 'Hello world' }

    describe 'association do' do

      let(:author_type) { instance_double('AuthorType') }
      let(:entry) { instance_double('Article', _slug: 'hello-world', author: association, authors: association) }

      before do
        allow(content_type_repository).to receive(:by_slug).with(:authors).and_return(:author_type)
      end

      context 'belongs_to association' do

        let(:association) { instance_double('Association', type: :belongs_to, association: true, target_class_slug: :authors, target_slugs: ['john-doe'], order_by: nil) }
        let(:name) { :author }

        before do
          expect(repository).to receive(:by_slug).with(:author_type, 'john-doe').and_return('John Doe')
        end

        it { expect(subject).to eq 'John Doe' }

      end

      context 'has_many association' do

        let(:association) { instance_double('Association', type: :has_many, association: true, target_class_slug: :authors, target_field: :article, order_by: 'created_at') }
        let(:name) { :authors }

        before do
          allow(association).to receive(:source).and_return(entry)
          expect(repository).to receive(:all).with(:author_type, { article: 'hello-world', order_by: 'created_at' }).and_return(%w(jane john))
        end

        it { expect(subject).to eq %w(jane john) }

      end

      context 'many_to_many association' do

        let(:association) { instance_double('Association', type: :many_to_many, association: true, target_class_slug: :authors, target_slugs: %w(jane john), order_by: nil) }
        let(:name) { :authors }

        before do
          expect(repository).to receive(:all).with(:author_type, { '_slug.in' => %w(jane john) }).and_return(%w(jane john))
        end

        it { expect(subject).to eq %w(jane john) }

      end

    end

  end

  describe '#all' do

    let(:conditions) { nil }
    subject { repository.all(type, conditions) }

    it { expect(subject.size).to eq 1 }

  end

end
