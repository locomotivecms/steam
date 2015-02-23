require 'spec_helper'

require_relative '../../../lib/locomotive/steam/adapters/filesystem.rb'
require_relative '../../../lib/locomotive/steam/adapters/mongodb.rb'

describe Locomotive::Steam::PageRepository do

  let(:site)        { Locomotive::Steam::Site.new(_id: 1, locales: %w(en fr nb)) }
  let(:locale)      { :en }
  let(:repository)  { Locomotive::Steam::PageRepository.new(adapter, site, locale) }

  # context 'MongoDB' do

  #   let(:adapter) { Locomotive::Steam::MongoDBAdapter.new('steam_test', ['127.0.0.1:27017']) }

  #   describe '#all' do
  #     subject { repository.all }
  #     it { expect(subject.size).to eq 1 }
  #   end

  #   describe '#query' do
  #     subject { repository.query { where(handle: 'acme') }.first }
  #     it { expect(subject.name).to eq 'My portfolio' }
  #   end

  # end

  context 'Filesystem' do

    let(:adapter) { Locomotive::Steam::FilesystemAdapter.new(default_fixture_site_path) }

    describe '#all' do
      subject { repository.all }
      it { expect(subject.size).to eq 21 }
    end

    describe '#query' do
      subject { repository.query { where(fullpath: 'index') }.first }
      it { expect(subject.title[:en]).to eq 'Home page' }
    end

    describe '#by_handle' do
      subject { repository.by_handle('our-music') }
      it { expect(subject.title[:en]).to eq 'Music' }
    end

    describe '#by_fullpath' do
      subject { repository.by_fullpath('archives/news') }
      it { expect(subject.title[:en]).to eq 'News archive' }
    end

  end

end
