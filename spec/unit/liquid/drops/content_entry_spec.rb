require 'spec_helper'

describe Locomotive::Steam::Liquid::Drops::ContentEntry do

  let(:site)      { instance_double('Site', default_locale: 'en') }
  let(:type)      { instance_double('Type', fields_by_name: { title: instance_double('Field', type: :string ) }) }
  let(:entry)     { instance_double('Article', _id: 42, localized_attributes: {}, content_type: type, title: 'Hello world', _label: 'Hello world', _slug: 'hello-world', _translated: false, seo_title: 'seo title', meta_keywords: 'keywords', meta_description: 'description', meta_robots: 'noindex', created_at: 0, updated_at: 1) }
  let(:assigns)   { {} }
  let(:services)  { Locomotive::Steam::Services.build_instance }
  let(:context)   { ::Liquid::Context.new(assigns, {}, { services: services, site: site, locale: 'en' }) }
  let(:drop)      { described_class.new(entry).tap { |d| d.context = context } }

  subject { drop }

  it 'gives access to general attributes' do
    expect(subject._id).to eq '42'
    expect(subject._label).to eq 'Hello world'
    expect(subject._slug).to eq 'hello-world'
    expect(subject._permalink).to eq 'hello-world'
    expect(subject.seo_title).to eq 'seo title'
    expect(subject.meta_keywords).to eq 'keywords'
    expect(subject.meta_description).to eq 'description'
    expect(subject.meta_robots).to eq 'noindex'
    expect(subject.created_at).to eq 0
    expect(subject.updated_at).to eq 1
  end

  describe '#liquid_method_missing (dynamic attributes)' do

    describe 'simple ones' do
      it { expect(subject.liquid_method_missing(:title)).to eq 'Hello world' }
    end

    describe 'relationship field' do

      let(:authors) { instance_double('AuthorsRepository', first: 'john', local_conditions: {}) }
      let(:type)    { instance_double('Type', fields_by_name: { authors: instance_double('Field', type: :has_many ) }) }
      let(:entry)   { instance_double('Article', content_type: type, authors: authors, localized_attributes: {}) }

      before { allow(authors).to receive(:dup).and_return(authors) }

      it { expect(subject.liquid_method_missing(:authors).first).to eq 'john' }

    end

  end

  describe '#next' do

    let(:next_entry) { instance_double('NextEntry', to_liquid: true) }

    before do
      expect(services.repositories.content_entry).to receive(:next).with(entry).and_return(next_entry)
    end

    it { expect(subject.next).to eq true }

  end

  describe '#previous' do

    let(:previous_entry) { instance_double('PreviousEntry', to_liquid: true) }

    before do
      expect(services.repositories.content_entry).to receive(:previous).with(entry).and_return(previous_entry)
    end

    it { expect(subject.previous).to eq true }

  end

  describe '#errors' do

    let(:errors) { instance_double('Errors', messages: { title: ['not_blank'] }, blank?: false) }

    before do
      allow(entry).to receive(:errors).and_return(errors)
    end

    it { expect(subject.errors).to eq('title' => ['not_blank']) }

    context 'no errors' do

      let(:errors) { instance_double('Errors', blank?: true) }

      it { expect(subject.errors).to eq(false) }

    end

  end

  describe 'i18n' do

    let(:entry) { instance_double('Article', content_type: type, localized_attributes: { title: true }, title: { en: 'Hello world', fr: 'Bonjour monde' }) }
    let(:drop)  { described_class.new(entry).tap { |d| d.context = context } }

    subject { drop.liquid_method_missing(:title) }

    it { is_expected.to eq 'Hello world' }

    context 'change the current locale of the context' do

      let(:context) { ::Liquid::Context.new(assigns, {}, { services: services, locale: 'fr', site: site }) }
      it { is_expected.to eq 'Bonjour monde' }

    end

  end

  describe '#to_hash' do

    describe 'belong_to content type' do

      let(:entry)       { instance_double('Article', _id: 42, localized_attributes: {}, content_type: type, title: 'Hello world', _label: 'Hello world', _slug: 'hello-world', _translated: false, seo_title: 'seo title', meta_keywords: 'keywords', meta_description: 'description', meta_robots: 'noindex', created_at: 0, updated_at: 1, author: author) }
      let(:type)        { instance_double('Type', fields_by_name: { title: instance_double('StringField', type: :string ), author: instance_double('Author', type: :belongs_to), picture: instance_double('FileField', type: :file), category: instance_double('SelectField', type: :select) }) }
      let(:author)      { instance_double('Author', _slug: 'john-doe', localized_attributes: {}) }
      let(:picture_field) { Locomotive::Steam::ContentEntry::FileField.new('foo.png', 'http://assets.dev', 0, 42) }

      before do
        allow(entry).to receive(:category).and_return('Test')
      end

      subject { drop.to_hash.stringify_keys }

      context 'corresponding hash value for id is not nil' do

        before do
          allow(entry).to receive(:to_hash).and_return({ '_id' => 1, 'title' => 'Hello world', 'picture' => picture_field, 'category_id' => 42, 'author_id' => 64 })
        end

        it { is_expected.to eq('id' => 1, '_id' => 1, 'title' => 'Hello world', 'picture' => 'http://assets.dev/foo.png?42', 'picture_url' => 'http://assets.dev/foo.png?42', 'category_id' => 42, 'category' => 'Test', 'author_id' => 64, 'author' => 'john-doe') }

      end

      context 'corresponding hash value for id is nil' do

        before do
          allow(entry).to receive(:to_hash).and_return({ '_id' => 1, 'title' => 'Hello world', 'picture' => picture_field, 'category_id' => 42 })
        end

        it { is_expected.to eq('id' => 1, '_id' => 1, 'title' => 'Hello world', 'picture' => 'http://assets.dev/foo.png?42', 'picture_url' => 'http://assets.dev/foo.png?42', 'category_id' => 42, 'category' => 'Test') }

      end

    end

  end

  describe '#as_json' do

    let(:entry)       { instance_double('Article', _id: 42, localized_attributes: {}, content_type: type, title: 'Hello world', _label: 'Hello world', _slug: 'hello-world', _translated: false, seo_title: 'seo title', meta_keywords: 'keywords', meta_description: 'description', meta_robots: 'noindex', created_at: 0, updated_at: 1, author: author, authors: authors) }
    let(:type)        { instance_double('Type', fields_by_name: { title: instance_double('StringField', type: :string ), author: instance_double('Author', type: :belongs_to), authors: instance_double('Author', type: :many_to_many), picture: instance_double('FileField', type: :file), category: instance_double('SelectField', type: :select) }) }
    let(:author)      { instance_double('Author', _slug: 'john-doe', localized_attributes: {}) }
    let(:authors)     { instance_double('Authors', all: [author]) }
    let(:picture_field) { Locomotive::Steam::ContentEntry::FileField.new('foo.png', 'http://assets.dev', 0, 42) }

    before do
      allow(entry).to receive(:to_hash).and_return({ '_id' => 1, 'title' => 'Hello world', 'picture' => picture_field, 'category_id' => 42, 'author_id' => 64 })
      allow(entry).to receive(:category).and_return('Test')
    end

    subject { drop.as_json }

    it { is_expected.to eq('id' => 1, '_id' => 1, 'title' => 'Hello world', 'picture' => 'http://assets.dev/foo.png?42', 'picture_url' => 'http://assets.dev/foo.png?42', 'category_id' => 42, 'category' => 'Test', 'author_id' => 64, 'author' => 'john-doe', 'authors' => ['john-doe']) }

  end

  describe '#conditions_for' do

    let(:name) { 'news' }

    subject { drop.send(:conditions_for, name) }

    before { context['with_scope'] = 42 }

    it { is_expected.to eq 42 }

    context 'the with_scope has been used before by another and different content type' do

      before { context['with_scope_content_type'] = 'articles' }
      it { is_expected.to eq nil }

    end

    context 'the with_scope has been used before by the same content type' do

      before { context['with_scope_content_type'] = 'news' }
      it { is_expected.to eq 42 }

    end

  end

end
