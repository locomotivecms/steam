require 'spec_helper'

describe Locomotive::Steam::Liquid::Drops::SectionContentProxy do

  let(:page_finder_service) { instance_double('PageFinderService') }
  let(:url_builder_service) { instance_double('UrlBuilderService') }
  let(:entry_service)       { instance_double('ContentEntryService') }
  let(:services)  { instance_double('Services', page_finder: page_finder_service, content_entry: entry_service, url_builder: url_builder_service) }
  let(:site)      { instance_double('Site', default_locale: 'en') }
  let(:context)   { ::Liquid::Context.new({}, {}, { locale: 'en', services: services, site: site }) }
  let(:drop)      { described_class.new(content, settings).tap { |d| d.context = context } }

  describe 'text type setting' do

    let(:settings)  { [{ 'id' => 'title', 'type' => 'text' }] }
    let(:content)   { { 'title' => 'Hello world' } }

    subject { drop.before_method(:title) }

    it { is_expected.to eq 'Hello world' }

    context 'with encoded urls (<DOMAIN>?link_target=....)' do

      let(:content) { { 'title' => 'Click <a href="http://station.locomotive.local:8080/#link_target=eyJ0eXBlIjoiX2V4dGVybmFsIiwidmFsdWUiOiJodHRwczovL3d3dy5ub2NvZmZlZS5mciIsImxhYmVsIjpbImV4dGVybmFsIiwiaHR0cHM6Ly93d3cubm9jb2ZmZWUuZnIiXX0=">here</a>' } }

      it { is_expected.to eq 'Click <a href="https://www.nocoffee.fr">here</a>' }

    end

  end

  describe 'url type setting' do

    let(:settings)  { [{ 'id' => 'link', 'type' => 'url' }] }

    subject { drop.before_method(:link) }

    describe 'url to a simple page' do

      let(:content)   { { 'link' => { 'type' => 'page', 'value' => 42 } } }
      let(:page)      { instance_double('Page') }

      it 'returns the url to the page' do
        expect(page_finder_service).to receive(:find_by_id).with(42).and_return(page)
        expect(url_builder_service).to receive(:url_for).with(page).and_return('/foo/bar')
        is_expected.to eq '/foo/bar'
      end

    end

    describe 'url to a content entry' do

      let(:content)   { { 'link' => { 'type' => 'content_entry', 'value' => { 'id' => 1, 'content_type_slug' => 'articles', 'page_id' => 42 } } } }
      let(:page)      { instance_double('PageTemplate', :content_entry= => true) }
      let(:entry)     { instance_double('Article') }

      it 'returns the url to the content entry' do
        expect(page_finder_service).to receive(:find_by_id).with(42).and_return(page)
        expect(entry_service).to receive(:find).with('articles', 1).and_return(entry)
        expect(url_builder_service).to receive(:url_for).with(page).and_return('/articles/1')
        is_expected.to eq '/articles/1'
      end

    end

    describe 'url to an external site' do

      let(:content) { { 'link' => { 'type' => 'external', 'value' => 'https://www.google.com' } } }

      it 'returns the url to the external site' do
        is_expected.to eq 'https://www.google.com'
      end

    end

  end

end
