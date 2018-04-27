require 'spec_helper'
require_relative '../../../lib/locomotive/steam/adapters/filesystem.rb'

describe Locomotive::Steam::SectionRepository do

  #TODO: site_id should not be passed like this
  #TODO: template_path should be shorter
  let(:sections)    { [{ name: 'Header', slug: 'header', site_id: 1, template_path: 'spec/fixtures/default/app/views/sections/header.liquid'  }] }
  let(:locale)      { :en }
  let(:site)        { instance_double('Site', _id: 1, default_locale: :en, locales: [:en, :fr]) }
  let(:adapter)     { Locomotive::Steam::FilesystemAdapter.new(nil) }
  let(:repository)  { described_class.new(adapter, site, locale) }

  before do
    allow(adapter).to receive(:collection).and_return(sections)
    adapter.cache = NoCacheStore.new
  end

  describe '#by_slug' do

    let(:name) { nil }
    subject { repository.by_slug(name) }

    it { is_expected.to eq nil }

    context 'existing section' do

      let(:name) { 'header' }
      subject { repository.by_slug(name) }
      it { expect(subject).to_not be_nil }
      it { expect(subject.class).to eq Locomotive::Steam::Section }
      it { expect(subject.name).to eq 'Header' }
      it { expect(subject[:template_path]).to eq 'spec/fixtures/default/app/views/sections/header.liquid' }

    end
  end
end

