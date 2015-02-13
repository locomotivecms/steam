require 'spec_helper'

describe Locomotive::Steam::Repositories::Filesystem::ContentEntry do

  # let(:fields)  { [{ title: { hint: 'Title of the article' } }, { author: { type: 'string', label: 'Fullname of the author' } }] }
  let(:type)    { instance_double('Articles', slug: 'articles', label_field_name: :title, localized_fields_names: [:title], fields_by_name: { title: instance_double('Field', type: :string) }) }
  let(:loader)  { instance_double('Loader', list_of_attributes: [{ content_type: type, _position: 0, _label: 'Update #1', title: { fr: 'Mise a jour #1' }, text: { en: 'added some free stuff', fr: 'phrase FR' }, date: '2009/05/12', category: 'General' }]) }
  let(:site)    { instance_double('Site', default_locale: :en, locales: [:en, :fr]) }
  let(:locale)  { :en }

  let(:repository) { Locomotive::Steam::Repositories::Filesystem::ContentEntry.new(loader, site, locale) }

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

  describe '#value_for' do

    let(:name)    { :title }
    let(:entry)   { instance_double('Article', title: 'Hello world') }

    subject { repository.value_for(name, entry) }

    it { is_expected.to eq 'Hello world' }

    context 'association' do

      # TODO

    end

  end

  describe '#all' do

    let(:conditions) { nil }
    subject { repository.all(type, conditions) }

    it { expect(subject.size).to eq 1 }

  end

  # describe '#by_slug' do

  #   let(:slug) { nil }
  #   subject { repository.by_slug(slug) }

  #   it { is_expected.to eq nil }

  #   context 'existing content type' do

  #     let(:slug) { 'articles' }
  #     it { expect(subject.name).to eq 'Articles' }

  #   end

  #   context 'slug is already a content type' do

  #     let(:slug) { instance_double('ContentType') }
  #     it { is_expected.to eq slug }

  #   end

  # end

end
