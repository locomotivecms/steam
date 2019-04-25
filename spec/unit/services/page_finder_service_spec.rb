require 'spec_helper'

describe Locomotive::Steam::PageFinderService do

  let(:site)        { instance_double('Site', default_locale: :en) }
  let(:repository)  { instance_double('PageRepository', site: site, locale: :en)}
  let(:service)     { described_class.new(repository) }

  describe '#find_by_id' do

    let(:id)    { 42 }
    let(:page)  { instance_double('Page', title: 'My page', localized_attributes: []) }

    subject { service.find_by_id(id) }

    it 'calls the repository to get the page and decorate it' do
      expect(repository).to receive(:find).with(42).and_return(page)
      expect(subject.title).to eq 'My page'
    end

  end

  describe '#match' do

    let(:path) { '/something' }
    let(:pages) { [instance_double('Page 1', title: 'Page #1', fullpath: 'something', position: 2, localized_attributes: []) ] }

    before { allow(repository).to receive(:matching_fullpath).and_return(pages) }

    subject { service.match(path) }

    it { expect(subject.map(&:title)).to eq(['Page #1']) }

    context '2 pages at the root of the site' do

      let(:pages) { [
        instance_double('Page 1', title: 'Page #1', fullpath: 'something', position: 2, localized_attributes: []),
        instance_double('Page 2', title: 'Page #2', fullpath: 'content_type_template', position: 1, localized_attributes: [])
      ] }

      it { expect(subject.map(&:title)).to eq(['Page #2', 'Page #1']) }

    end

    context '2 pages in the same folder' do

      let(:pages) { [
        instance_double('Page 1', title: 'Page #1', fullpath: 'folder/something', position: 2, localized_attributes: []),
        instance_double('Page 2', title: 'Page #2', fullpath: 'folder/content_type_template', position: 1, localized_attributes: [])
      ] }

      it { expect(subject.map(&:title)).to eq(['Page #2', 'Page #1']) }

    end

    context '2 pages in different folder' do

      let(:pages) { [
        instance_double('Page 1', title: 'Page #1', fullpath: 'folder/something', position: 2, localized_attributes: []),
        instance_double('Page 2', title: 'Page #2', fullpath: 'anotherfolder/content_type_template', position: 1, localized_attributes: [])
      ] }

      it { expect(subject.map(&:title)).to eq(['Page #1', 'Page #2']) }

    end

  end
end

