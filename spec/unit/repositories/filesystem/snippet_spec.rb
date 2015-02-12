require 'spec_helper'

describe Locomotive::Steam::Repositories::Filesystem::Snippet do

  let(:loader)  { instance_double('Loader', list_of_attributes: [{ name: 'Simple', slug: 'simple', template_path: { en: 'simple.yml' } }]) }
  let(:site)    { instance_double('Site', default_locale: :en, locales: [:en, :fr]) }
  let(:locale)  { :en }

  let(:repository) { Locomotive::Steam::Repositories::Filesystem::Snippet.new(loader, site, locale) }

  describe '#collection' do

    subject { repository.send(:collection).first }

    it { expect(subject.class).to eq Locomotive::Steam::Repositories::Filesystem::Models::Snippet }

    it 'applies the sanitizer' do
      expect(subject[:template_path]).to eq({ en: 'simple.yml', fr: 'simple.yml' })
    end

  end

  describe '#by_slug' do

    let(:name) { nil }
    subject { repository.by_slug(name) }

    it { is_expected.to eq nil }

    context 'existing snippet' do

      let(:name) { 'simple' }
      it { expect(subject.name).to eq 'Simple' }

    end

  end

end
