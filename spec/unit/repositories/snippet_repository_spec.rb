require 'spec_helper'

require_relative '../../../lib/locomotive/steam/adapters/filesystem.rb'

describe Locomotive::Steam::SnippetRepository do

  let(:snippets)    { [{ name: 'Simple', slug: 'simple', template_path: { en: 'simple.yml' } }] }
  let(:locale)      { :en }
  let(:site)        { instance_double('Site', _id: 1, default_locale: :en, locales: [:en, :fr]) }
  let(:adapter)     { Locomotive::Steam::FilesystemAdapter.new(nil) }
  let(:repository)  { described_class.new(adapter, site, locale) }

  before do
    allow(adapter).to receive(:collection).and_return(snippets)
    adapter.cache = NoCacheStore.new
  end

  describe '#by_slug' do

    let(:name) { nil }
    subject { repository.by_slug(name) }

    it { is_expected.to eq nil }

    context 'existing snippet' do

      let(:name) { 'simple' }
      it { expect(subject.class).to eq Locomotive::Steam::Snippet }
      it { expect(subject.name).to eq 'Simple' }
      it { expect(subject[:template_path][:en]).to eq 'simple.yml' }
      it { expect(subject[:template_path][:fr]).to eq 'simple.yml' }

    end

  end

end
