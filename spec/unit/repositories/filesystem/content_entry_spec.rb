require 'spec_helper'

describe Locomotive::Steam::Repositories::Filesystem::ContentEntry do

  let(:type)    { instance_double('Articles', slug: 'articles', order_by: nil, label_field_name: :title, localized_fields_names: [:title], fields_by_name: { title: instance_double('Field', name: :title, type: :string) }) }
  let(:entries) { [{ content_type: type, _position: 0, _label: 'Update #1', title: { fr: 'Mise a jour #1' }, text: { en: 'added some free stuff', fr: 'phrase FR' }, date: '2009/05/12', category: 'General' }] }
  let(:loader)  { instance_double('Loader', list_of_attributes: entries) }
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
      it { expect(subject._slug).to eq({ en: 'update-number-1', fr: 'mise-a-jour-number-1' }) }
      it { expect(subject.content_type).to eq type }

    end

  end

  describe '#all' do

    let(:conditions) { nil }
    subject { repository.all(type, conditions) }

    it { expect(subject.size).to eq 1 }

  end

  describe '#build' do

    let(:attributes) { { title: 'Hello world' } }
    subject { repository.build(type, attributes) }

    it { expect(subject.title).to eq 'Hello world' }

  end

  describe '#persist' do

    let(:entry) { instance_double('NewEntry', _visible: true, content_type: type, _label: 'Hello world') }
    subject { repository.persist(entry) }

    before do
      expect(entry).to receive(:[]).with(:_slug).and_return(nil)
      expect(entry).to receive(:[]=).with(:_slug, 'hello-world')
    end

    it { expect { subject }.to change { repository.all(type).size }.by(1) }

  end

  describe '#exists?' do

    let(:conditions) { {} }
    subject { repository.exists?(type, conditions) }

    it { expect(subject).to eq true }

    context 'more specific conditions' do

      let(:conditions) { { '_slug' => 'update-number-1' } }
      it { expect(subject).to eq true }

    end

    context 'conditions which do match any entries' do

      let(:conditions) { { '_slug' => 'foo' } }
      it { expect(subject).to eq false }

    end

  end

  describe '#by_slug' do

    let(:slug) { nil }
    subject { repository.by_slug(type, slug) }

    it { is_expected.to eq nil }

    context 'existing slug' do
      let(:slug) { 'update-number-1' }
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

  describe '#next' do

    let(:type) { instance_double('Articles', slug: 'articles', order_by: '_position asc', label_field_name: :title, localized_fields_names: [:title], fields_by_name: { title: instance_double('Field', name: :title, type: :string) }) }
    let(:entries) do
      [
        { content_type: type, _position: 0, _label: 'Update #1', title: { fr: 'Mise a jour #1' }, text: { en: 'added some free stuff', fr: 'phrase FR' }, date: '2009/05/12', category: 'General' },
        { content_type: type, _position: 1, _label: 'Update #2', title: { fr: 'Mise a jour #2' }, text: { en: 'bla bla', fr: 'blabbla' }, date: '2009/05/12', category: 'General' },
        { content_type: type, _position: 2, _label: 'Update #3', title: { fr: 'Mise a jour #2' }, text: { en: 'bla bla', fr: 'blabbla' }, date: '2009/05/12', category: 'General' }
      ]
    end

    let(:entry) { nil }
    subject { repository.next(entry) }

    it { is_expected.to eq nil }

    context 'being last' do

      let(:entry) { instance_double('Entry', content_type: type, _position: 2) }
      it { repository.send(:collection, type).inspect; is_expected.to eq nil }

    end

    context 'being middle' do

      let(:entry) { instance_double('Entry', content_type: type, _position: 1) }
      it { expect(subject._position).to eq 2 }

    end

  end

  describe '#previous' do

    let(:type) { instance_double('Articles', slug: 'articles', order_by: '_position asc', label_field_name: :title, localized_fields_names: [:title], fields_by_name: { title: instance_double('Field', name: :title, type: :string) }) }
    let(:entries) do
      [
        { content_type: type, _position: 0, _label: 'Update #1', title: { fr: 'Mise a jour #1' }, text: { en: 'added some free stuff', fr: 'phrase FR' }, date: '2009/05/12', category: 'General' },
        { content_type: type, _position: 1, _label: 'Update #2', title: { fr: 'Mise a jour #2' }, text: { en: 'bla bla', fr: 'blabbla' }, date: '2009/05/12', category: 'General' },
        { content_type: type, _position: 2, _label: 'Update #3', title: { fr: 'Mise a jour #2' }, text: { en: 'bla bla', fr: 'blabbla' }, date: '2009/05/12', category: 'General' }
      ]
    end

    let(:entry) { nil }
    subject { repository.previous(entry) }

    it { is_expected.to eq nil }

    context 'being first' do

      let(:entry) { instance_double('Entry', content_type: type, _position: 0) }
      it { repository.send(:collection, type).inspect; is_expected.to eq nil }

    end

    context 'being middle' do

      let(:entry) { instance_double('Entry', content_type: type, _position: 1) }
      it { expect(subject._position).to eq 0 }

    end

  end

  describe '#group_by_select_option' do

    let(:type) { nil }
    let(:name) { nil }

    subject { repository.group_by_select_option(type, name) }

    it { is_expected.to eq({}) }

    context 'select field' do

      let(:fields) do
        {
          title:    instance_double('TitleField', name: :title, type: :string),
          category: instance_double('SelectField', name: :category, type: :select, select_options: { en: ['cooking', 'bread'], fr: ['cuisine', 'pain'] })
        }
      end
      let(:type) { instance_double('Articles', slug: 'articles', order_by: '_position asc', label_field_name: :title, localized_fields_names: [:title, :category], fields_by_name: fields) }
      let(:name) { :category }

      let(:entries) do
        [
          { content_type: type, _position: 0, _label: 'Recipe #1', category: 'cooking' },
          { content_type: type, _position: 1, _label: 'Recipe #2', category: 'bread' },
          { content_type: type, _position: 2, _label: 'Recipe #3', category: 'bread' },
          { content_type: type, _position: 3, _label: 'Recipe #4', category: 'unknown' }
        ]
      end

      before { allow(content_type_repository).to receive(:select_options).and_return(%w(cooking wine bread)) }

      it { expect(subject.size).to eq 4 }
      it { expect(subject.map { |h| h[:name] }).to eq ['cooking', 'wine', 'bread', nil] }
      it { expect(subject.map { |h| h[:entries].size }).to eq [1, 0, 2, 1] }

    end

  end

end
