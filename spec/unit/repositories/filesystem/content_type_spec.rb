require 'spec_helper'

describe Locomotive::Steam::Repositories::Filesystem::ContentType do

  let(:fields)  { [{ title: { hint: 'Title of the article', type: 'string' } }, { author: { type: 'string', label: 'Fullname of the author' } }] }
  let(:loader)  { instance_double('Loader', list_of_attributes: [{ slug: 'articles', name: 'Articles', fields: fields }]) }
  let(:site)    { instance_double('Site', default_locale: :en, locales: [:en, :fr]) }
  let(:locale)  { :en }

  let(:repository) { Locomotive::Steam::Repositories::Filesystem::ContentType.new(loader, site) }

  describe '#collection' do

    subject { repository.send(:collection).first }

    it { expect(subject.class).to eq Locomotive::Steam::Repositories::Filesystem::Models::ContentType }

    it 'applies the sanitizer' do
      expect(subject.name).to eq('Articles')
      expect(subject.slug).to eq('articles')
      expect(subject.fields.size).to eq 2
      expect(subject.fields_by_name.size).to eq 2
    end

    describe 'a field of the first element' do

      subject { repository.send(:collection).first.fields.first }

      it { expect(subject.class).to eq Locomotive::Steam::Repositories::Filesystem::Models::ContentTypeField }

      it 'has properties' do
        expect(subject.name).to eq :title
        expect(subject.label).to eq 'Title'
        expect(subject.hint).to eq 'Title of the article'
        expect(subject.type).to eq :string
      end

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

end
