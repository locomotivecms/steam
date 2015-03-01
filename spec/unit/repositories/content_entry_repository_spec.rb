require 'spec_helper'

require_relative '../../../lib/locomotive/steam/adapters/filesystem.rb'

describe Locomotive::Steam::ContentEntryRepository do

  let(:type)    { instance_double('Articles', _id: 1, slug: 'articles', order_by: nil, label_field_name: :title, localized_fields_names: [:title], belongs_to_fields: [], fields_by_name: { title: instance_double('Field', name: :title, type: :string) }) }
  let(:entries) { [{ content_type_id: 1, _position: 0, _label: 'Update #1', title: { fr: 'Mise a jour #1' }, text: { en: 'added some free stuff', fr: 'phrase FR' }, date: '2009/05/12', category: 'General' }] }
  let(:locale)  { :en }
  let(:site)    { instance_double('Site', _id: 1, default_locale: :en, locales: %i(en fr)) }
  let(:adapter) { Locomotive::Steam::FilesystemAdapter.new(nil) }

  let(:content_type_repository) { instance_double('ContentTypeRepository') }
  let(:repository)  { described_class.new(adapter, site, locale, content_type_repository) }

  before do
    allow(adapter).to receive(:collection).and_return(entries)
    adapter.cache = NoCacheStore.new
  end

  describe 'belongs_to' do

    let(:field)       { instance_double('Field', name: :author, type: :belongs_to, association_options: { class_name: 'authors' }) }
    let(:type)        { instance_double('Articles', _id: 1, slug: 'articles', order_by: nil, label_field_name: :title, belongs_to_fields: [field], fields_by_name: { title: instance_double('Field', name: :title, type: :string), author: field }, localized_fields_names: []) }
    let(:other_type)  { instance_double('Authors', _id: 2, slug: 'authors', order_by: nil, label_field_name: :name, fields_by_name: { name: instance_double('Field', name: :name, type: :string) }, localized_fields_names: []) }
    let(:entries)     { [{ content_type_id: 1, title: 'Hello world', author_id: 'john-doe' }] }

    let(:type_repository) { instance_double('ContentTypeRepository', belongs_to: [field]) }

    before do
      allow(type).to receive(:fields).and_return(type_repository)
    end

    subject { repository.with(type).by_slug('hello-world') }

    it { expect(subject.author.class).to eq Locomotive::Steam::Models::BelongsToAssociation }
    # it { expect(subject.author.name).to eq 'John Doe' }

  end

  describe '#all' do

    let(:conditions) { nil }

    subject { repository.with(type).all(conditions) }

    it { expect(subject.size).to eq 1 }

    describe 'first element' do

      subject { repository.with(type).all(conditions).first }

      it { expect(subject.class).to eq Locomotive::Steam::ContentEntry }
      it { expect(subject._label.translations).to eq('en' => 'Update #1', 'fr' => 'Mise a jour #1') }
      it { expect(subject._slug.translations).to eq('en' => 'update-number-1', 'fr' => 'mise-a-jour-number-1') }
      it { expect(subject.title.translations).to eq('en' => 'Update #1', 'fr' => 'Mise a jour #1') }
      it { expect(subject.content_type).to eq type }

    end

  end

  describe '#build' do

    let(:attributes) { { title: 'Hello world' } }
    subject { repository.with(type).build(attributes) }

    it { expect(subject.title[:en]).to eq 'Hello world' }
    it { expect(subject.content_type).to eq type }

  end

  # describe '#persist' do

  #   # let(:entry) { instance_double('NewEntry', _visible: true, content_type: type, _label: 'Hello world', attributes: { title: 'Hello world' }) }
  #   # subject { repository.persist(entry) }

  #   # before do
  #   #   expect(entry).to receive(:[]).with(:_slug).and_return(nil)
  #   #   expect(entry).to receive(:[]=).with(:_slug, 'hello-world')
  #   #   expect(loader).to receive(:write).with(type, { title: 'Hello world' })
  #   # end

  #   # it { expect { subject }.to change { repository.all(type).size }.by(1) }

  # end

  describe '#exists?' do

    let(:conditions) { {} }
    subject { repository.with(type).exists?(conditions) }

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
    subject { repository.with(type).by_slug(slug) }

    it { is_expected.to eq nil }

    context 'existing slug' do
      let(:slug) { 'update-number-1' }
      it { expect(subject.title.translations).to eq('en' => 'Update #1', 'fr' => 'Mise a jour #1') }
    end

  end

  # describe '#value_for' do

  #   let(:name)    { :title }
  #   let(:entry)   { instance_double('Article', title: 'Hello world') }

  #   subject { repository.value_for(name, entry) }

  #   it { is_expected.to eq 'Hello world' }

  #   describe 'association do' do

  #     let(:author_type) { instance_double('AuthorType') }
  #     let(:entry) { instance_double('Article', _slug: 'hello-world', author: association, authors: association) }

  #     before do
  #       allow(content_type_repository).to receive(:by_slug).with(:authors).and_return(:author_type)
  #     end

  #     context 'belongs_to association' do

  #       let(:association) { instance_double('Association', type: :belongs_to, association: true, target_class_slug: :authors, target_slugs: ['john-doe'], order_by: nil) }
  #       let(:name) { :author }

  #       before do
  #         expect(repository).to receive(:by_slug).with(:author_type, 'john-doe').and_return('John Doe')
  #       end

  #       it { expect(subject).to eq 'John Doe' }

  #     end

  #     # context 'has_many association' do

  #     #   let(:association) { instance_double('Association', type: :has_many, association: true, target_class_slug: :authors, target_field: :article, order_by: 'created_at') }
  #     #   let(:name) { :authors }

  #     #   before do
  #     #     allow(association).to receive(:source).and_return(entry)
  #     #     expect(repository).to receive(:all).with(:author_type, { article: 'hello-world', order_by: 'created_at' }).and_return(%w(jane john))
  #     #   end

  #     #   it { expect(subject).to eq %w(jane john) }

  #     # end

  #     # context 'many_to_many association' do

  #     #   let(:association) { instance_double('Association', type: :many_to_many, association: true, target_class_slug: :authors, target_slugs: %w(jane john), order_by: nil) }
  #     #   let(:name) { :authors }

  #     #   before do
  #     #     expect(repository).to receive(:all).with(:author_type, { '_slug.in' => %w(jane john) }).and_return(%w(jane john))
  #     #   end

  #     #   it { expect(subject).to eq %w(jane john) }

  #     # end

  #   end

  # end

  describe '#next' do

    let(:type) { instance_double('Articles', _id: 1, slug: 'articles', order_by: '_position asc', label_field_name: :title, localized_fields_names: [:title], belongs_to_fields: [], fields_by_name: { title: instance_double('Field', name: :title, type: :string) }) }
    let(:entries) do
      [
        { content_type_id: 1, _position: 0, _label: 'Update #1', title: { fr: 'Mise a jour #1' }, text: { en: 'added some free stuff', fr: 'phrase FR' }, date: '2009/05/12', category: 'General' },
        { content_type_id: 1, _position: 1, _label: 'Update #2', title: { fr: 'Mise a jour #2' }, text: { en: 'bla bla', fr: 'blabbla' }, date: '2009/05/12', category: 'General' },
        { content_type_id: 1, _position: 2, _label: 'Update #3', title: { fr: 'Mise a jour #2' }, text: { en: 'bla bla', fr: 'blabbla' }, date: '2009/05/12', category: 'General' }
      ]
    end

    let(:entry) { nil }
    subject { repository.next(entry) }

    it { is_expected.to eq nil }

    context 'being last' do

      let(:entry) { instance_double('Entry', content_type: type, _position: 2) }
      it { is_expected.to eq nil }

    end

    context 'being middle' do

      let(:entry) { instance_double('Entry', content_type: type, _position: 1) }
      it { expect(subject._position).to eq 2 }

    end

  end

  describe '#previous' do

    let(:type) { instance_double('Articles', _id: 1, slug: 'articles', order_by: '_position asc', label_field_name: :title, localized_fields_names: [:title], belongs_to_fields: [], fields_by_name: { title: instance_double('Field', name: :title, type: :string) }) }
    let(:entries) do
      [
        { content_type_id: 1, _position: 0, _label: 'Update #1', title: { fr: 'Mise a jour #1' }, text: { en: 'added some free stuff', fr: 'phrase FR' }, date: '2009/05/12', category: 'General' },
        { content_type_id: 1, _position: 1, _label: 'Update #2', title: { fr: 'Mise a jour #2' }, text: { en: 'bla bla', fr: 'blabbla' }, date: '2009/05/12', category: 'General' },
        { content_type_id: 1, _position: 2, _label: 'Update #3', title: { fr: 'Mise a jour #2' }, text: { en: 'bla bla', fr: 'blabbla' }, date: '2009/05/12', category: 'General' }
      ]
    end

    let(:entry) { nil }
    subject { repository.previous(entry) }

    it { is_expected.to eq nil }

    context 'being first' do

      let(:entry) { instance_double('Entry', content_type: type, _position: 0) }
      it { is_expected.to eq nil }

    end

    context 'being middle' do

      let(:entry) { instance_double('Entry', content_type: type, _position: 1) }
      it { expect(subject._position).to eq 0 }

    end

  end

  describe '#group_by_select_option' do

    let(:type) { nil }
    let(:name) { nil }

    subject { repository.with(type).group_by_select_option(name) }

    it { is_expected.to eq({}) }

    context 'select field' do

      let(:fields) do
        {
          title:    instance_double('TitleField', name: :title, type: :string),
          category: instance_double('SelectField', name: :category, type: :select, select_options: { en: ['cooking', 'bread'], fr: ['cuisine', 'pain'] })
        }
      end
      let(:type) { instance_double('Articles', _id: 1, slug: 'articles', order_by: '_position asc', label_field_name: :title, localized_fields_names: [:title, :category], belongs_to_fields: [], fields_by_name: fields) }
      let(:name) { :category }

      let(:entries) do
        [
          { content_type_id: 1, _position: 0, _label: 'Recipe #1', category: 'cooking' },
          { content_type_id: 1, _position: 1, _label: 'Recipe #2', category: 'bread' },
          { content_type_id: 1, _position: 2, _label: 'Recipe #3', category: 'bread' },
          { content_type_id: 1, _position: 3, _label: 'Recipe #4', category: 'unknown' }
        ]
      end

      before { allow(content_type_repository).to receive(:select_options).and_return(%w(cooking wine bread)) }

      it { expect(subject.size).to eq 4 }
      it { expect(subject.map { |h| h[:name] }).to eq ['cooking', 'wine', 'bread', nil] }
      it { expect(subject.map { |h| h[:entries].size }).to eq [1, 0, 2, 1] }

    end

  end

end
