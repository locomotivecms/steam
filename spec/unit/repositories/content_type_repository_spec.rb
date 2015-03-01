require 'spec_helper'

require_relative '../../../lib/locomotive/steam/adapters/filesystem.rb'

describe Locomotive::Steam::ContentTypeRepository do

  let(:fields)      { [{ name: :title, hint: 'Title of the article', type: 'string' }, { name: :author, type: 'string', label: 'Fullname of the author' }] }
  let(:types)       { [{ slug: 'articles', name: 'Articles', entries_custom_fields: fields }] }
  let(:locale)      { :en }
  let(:site)        { instance_double('Site', _id: 1, default_locale: :en, locales: %i(en fr)) }
  let(:adapter)     { Locomotive::Steam::FilesystemAdapter.new(nil) }
  let(:repository)  { described_class.new(adapter, site, locale) }

  before do
    allow(adapter).to receive(:collection).and_return(types)
    adapter.cache = NoCacheStore.new
  end

  describe '#all' do

    subject { repository.all }

    it { expect(subject.size).to eq 1 }

    describe 'first element' do

      subject { repository.all.first }

      it { expect(subject.class).to eq Locomotive::Steam::ContentType }
      it { expect(subject.fields.all.size).to eq 2 }

    end

  end

  describe '#by_slug' do

    let(:slug) { nil }
    subject { repository.by_slug(slug) }

    it { is_expected.to eq nil }

    context 'existing content type' do

      let(:slug) { 'articles' }
      it { expect(subject.name).to eq 'Articles' }

    end

    context 'slug is already a content type' do

      let(:slug) { instance_double('ContentType') }
      it { is_expected.to eq slug }

    end

  end

  describe '#fields_for' do

    let(:type) { nil }
    subject { repository.fields_for(type) }

    it { is_expected.to eq nil }

    context 'with fields' do

      let(:type) { instance_double('ContentType', fields: [true]) }
      it { is_expected.to eq([true]) }

    end

  end

  describe '#look_for_unique_fields' do

    let(:type) { nil }
    subject { repository.look_for_unique_fields(type) }

    it { is_expected.to eq nil }

    context 'with fields' do

      let(:field)   { instance_double('Field', name: :title) }
      let(:target)  { instance_double('ContentTypeFieldRepository', unique: { title: field }) }
      let(:type)    { instance_double('ContentType', fields: target) }

      it { expect(subject).to eq(title: field) }

    end

  end

  describe '#select_options' do

    let(:type)  { repository.by_slug('articles') }
    let(:name)  { nil }

    subject { repository.select_options(type, name) }

    it { is_expected.to eq nil }

    context 'a select field' do

      let(:fields) do
        [
          { name: 'title', hint: 'Title of the article', type: 'string' },
          { name: 'category', type: :select, select_options: [{ name: { en: 'cooking', fr: 'cuisine' }, position: 0 }, { name: { en: 'bread', fr: 'pain' }, position: 1 }] }
        ]
      end
      let(:name) { :category }

      it { expect(subject.map { |o| o.name[:en] }).to eq %w(cooking bread) }

      context 'not a select field' do

        let(:name) { :title }
        it { is_expected.to eq nil }

      end

    end

  end

end
