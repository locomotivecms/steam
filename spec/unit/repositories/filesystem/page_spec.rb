require 'spec_helper'

describe Locomotive::Steam::Repositories::Filesystem::Page do

  let(:loader)  { instance_double('Loader', list_of_attributes: [{ title: { en: 'Home' }, slug: { en: 'index' }, _fullpath: 'index', template_path: { en: 'index.liquid' } }]) }
  let(:site)    { instance_double('Site', default_locale: :en, locales: [:en, :fr]) }
  let(:locale)  { :en }

  let(:repository) { Locomotive::Steam::Repositories::Filesystem::Page.new(loader, site, locale) }

  describe '#collection' do

    subject { repository.send(:collection).first }

    it { expect(subject.class).to eq Locomotive::Steam::Repositories::Filesystem::Models::Page }

    it 'applies the sanitizer' do
      expect(subject[:fullpath]).to eq({ en: 'index' })
      expect(subject.depth).to eq 0
    end

  end

  describe '#by_fullpath' do

    let(:path) { nil }
    subject { repository.by_fullpath(path) }

    it { is_expected.to eq nil }

    context 'existing page' do

      let(:path) { 'index' }
      it { expect(subject.title).to eq({ en: 'Home' }) }

    end

  end

end
